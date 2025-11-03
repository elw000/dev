from flask import Flask, jsonify, request
import os
import socket
import psycopg2
import redis
import logging
from prometheus_client import Counter, Histogram, generate_latest
from pythonjsonlogger import jsonlogger
import time

# إعداد Logging
logHandler = logging.StreamHandler()
formatter = jsonlogger.JsonFormatter()
logHandler.setFormatter(formatter)
logger = logging.getLogger()
logger.addHandler(logHandler)
logger.setLevel(logging.INFO)

app = Flask('hello-devops')

# Prometheus Metrics
REQUEST_COUNT = Counter('app_requests_total', 'Total requests', ['method', 'endpoint', 'status'])
REQUEST_LATENCY = Histogram('app_request_latency_seconds', 'Request latency')

# Database Connection
def get_db_connection():
    try:
        conn = psycopg2.connect(
            host=os.environ.get('DB_HOST', 'postgres'),
            database=os.environ.get('DB_NAME', 'devops_db'),
            user=os.environ.get('DB_USER', 'postgres'),
            password=os.environ.get('DB_PASSWORD', 'postgres')
        )
        return conn
    except Exception as e:
        logger.error(f"Database connection failed: {e}")
        return None

# Redis Connection
def get_redis_connection():
    try:
        r = redis.Redis(
            host=os.environ.get('REDIS_HOST', 'redis'),
            port=int(os.environ.get('REDIS_PORT', 6379)),
            decode_responses=True
        )
        r.ping()
        return r
    except Exception as e:
        logger.error(f"Redis connection failed: {e}")
        return None

@app.before_request
def before_request():
    request.start_time = time.time()

@app.after_request
def after_request(response):
    latency = time.time() - request.start_time
    REQUEST_LATENCY.observe(latency)
    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.path,
        status=response.status_code
    ).inc()
    
    logger.info({
        'method': request.method,
        'path': request.path,
        'status': response.status_code,
        'latency': latency,
        'ip': request.remote_addr
    })
    
    return response

@app.route('/')
def hello():
    hostname = socket.gethostname()
    version = os.environ.get('APP_VERSION', 'v2.0-devops')
    
    # محاولة الحصول على visitor count من Redis
    visitor_count = "N/A"
    try:
        r = get_redis_connection()
        if r:
            visitor_count = r.incr('visitor_count')
    except Exception as e:
        logger.warning(f"Redis error: {e}")
    
    return f"""
🚀 Hello from DevOps Project!
📦 Version: {version}
🖥️  Pod: {hostname}
👥 Visitors: {visitor_count}
🔧 Status: All systems operational
"""

@app.route('/health')
def health():
    health_status = {
        "status": "healthy",
        "version": os.environ.get('APP_VERSION', 'v2.0-devops'),
        "hostname": socket.gethostname(),
        "services": {}
    }
    
    # Check Database
    try:
        conn = get_db_connection()
        if conn:
            conn.close()
            health_status["services"]["database"] = "up"
        else:
            health_status["services"]["database"] = "down"
    except:
        health_status["services"]["database"] = "down"
    
    # Check Redis
    try:
        r = get_redis_connection()
        if r:
            health_status["services"]["redis"] = "up"
        else:
            health_status["services"]["redis"] = "down"
    except:
        health_status["services"]["redis"] = "down"
    
    return jsonify(health_status)

@app.route('/ready')
def ready():
    """Readiness probe - checks if app can serve traffic"""
    try:
        # Check critical dependencies
        conn = get_db_connection()
        if conn:
            conn.close()
            return jsonify({"status": "ready"}), 200
        else:
            return jsonify({"status": "not ready", "reason": "database unavailable"}), 503
    except Exception as e:
        return jsonify({"status": "not ready", "reason": str(e)}), 503

@app.route('/metrics')
def metrics():
    """Prometheus metrics endpoint"""
    return generate_latest()

@app.route('/api/visitors')
def get_visitors():
    """Get visitor statistics"""
    try:
        r = get_redis_connection()
        if r:
            count = r.get('visitor_count') or 0
            return jsonify({"visitors": int(count)})
        else:
            return jsonify({"error": "Redis unavailable"}), 503
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/data', methods=['GET', 'POST'])
def data():
    """Database operations example"""
    if request.method == 'POST':
        try:
            conn = get_db_connection()
            if not conn:
                return jsonify({"error": "Database unavailable"}), 503
            
            cur = conn.cursor()
            data = request.json
            cur.execute(
                "INSERT INTO app_data (key, value) VALUES (%s, %s) ON CONFLICT (key) DO UPDATE SET value = %s",
                (data.get('key'), data.get('value'), data.get('value'))
            )
            conn.commit()
            cur.close()
            conn.close()
            
            return jsonify({"status": "success", "data": data}), 201
        except Exception as e:
            logger.error(f"Database error: {e}")
            return jsonify({"error": str(e)}), 500
    
    else:  # GET
        try:
            conn = get_db_connection()
            if not conn:
                return jsonify({"error": "Database unavailable"}), 503
            
            cur = conn.cursor()
            cur.execute("SELECT key, value FROM app_data")
            rows = cur.fetchall()
            cur.close()
            conn.close()
            
            data = [{"key": row[0], "value": row[1]} for row in rows]
            return jsonify({"data": data})
        except Exception as e:
            logger.error(f"Database error: {e}")
            return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    logger.info("Starting DevOps Application...")
    app.run(host='0.0.0.0', port=8080)