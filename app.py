import redis, string, random, time, logging
from flask import Flask, render_template, request, jsonify
from os import environ
from prometheus_client import Counter, Histogram, start_http_server, generate_latest


LOGLEVEL=environ.get('LOGLEVEL', 'INFO')
logging.basicConfig(format='[%(threadName)s] [%(asctime)s] [%(filename)s:%(lineno)d] %(levelname)s - %(message)s', level=LOGLEVEL)
app = Flask(__name__)

redis_host = environ.get('REDIS_HOST', 'redis-service')
redis_port = 6379
redis_password = ""

r = redis.StrictRedis(host=redis_host, port=redis_port, password=redis_password, decode_responses=True)

SENHA_GERADA_COUNTER = Counter('senha_gerada', 'Contador de senhas geradas')
HTTP_REQUEST_COUNT = Counter(
    'http_request_count',
    'HTTP request count',
    ['method', 'endpoint', 'http_status_code']
)
HTTP_REQUEST_LATENCY_SECONDS = Histogram(
    'http_request_latency_seconds',
    'Time spent to process HTTP request',
    ['method', 'endpoint', 'http_status_code']
)

def criar_senha(tamanho, incluir_numeros, incluir_caracteres_especiais):
    caracteres = string.ascii_letters

    if incluir_numeros:
        caracteres += string.digits

    if incluir_caracteres_especiais:
        caracteres += string.punctuation

    senha = ''.join(random.choices(caracteres, k=tamanho))

    return senha

@app.route('/', methods=['GET', 'POST'])
def index():
    try:
        start_time = time.time()
        if request.method == 'POST':
            tamanho = int(request.form.get('tamanho', 8))
            incluir_numeros = request.form.get('incluir_numeros') == 'on'
            incluir_caracteres_especiais = request.form.get('incluir_caracteres_especiais') == 'on'
            senha = criar_senha(tamanho, incluir_numeros, incluir_caracteres_especiais)

            r.lpush("senhas", senha)
            SENHA_GERADA_COUNTER.inc()
        senhas = r.lrange("senhas", 0, 9)
        status_code = 200
        if senhas:
            senhas_geradas = [{"id": index + 1, "senha": senha} for index, senha in enumerate(senhas)]
            return render_template('index.html', senhas_geradas=senhas_geradas, senha=senhas_geradas[0]['senha'] or '' )
        return render_template('index.html')
    except Exception as error:
        status_code = 500
        logging.error(f"An error occurred: {error}")
    finally:
        HTTP_REQUEST_COUNT.labels(request.method, '/', status_code).inc()
        HTTP_REQUEST_LATENCY_SECONDS.labels(request.method, '/', status_code).observe(time.time() - start_time)


@app.route('/api/gerar-senha', methods=['POST'])
def gerar_senha_api():
    try:
        start_time = time.time()
        dados = request.get_json()

        tamanho = int(dados.get('tamanho', 8))
        incluir_numeros = dados.get('incluir_numeros', False)
        incluir_caracteres_especiais = dados.get('incluir_caracteres_especiais', False)

        senha = criar_senha(tamanho, incluir_numeros, incluir_caracteres_especiais)
        r.lpush("senhas", senha)
        SENHA_GERADA_COUNTER.inc()
        status_code = 200
        return jsonify({"senha": senha})
    except Exception as error:
        status_code = 500
        logging.error(f"An error occurred: {error}")
    else:
        HTTP_REQUEST_COUNT.labels(request.method, '/api/gerar-senha', status_code).inc()
        HTTP_REQUEST_LATENCY_SECONDS.labels(request.method, '/api/gerar-senha', status_code).observe(time.time() - start_time)

@app.route('/api/senhas', methods=['GET'])
def listar_senhas():
    try:
        start_time = time.time()
        senhas = r.lrange("senhas", 0, 9)

        resposta = [{"id": index + 1, "senha": senha} for index, senha in enumerate(senhas)]
        status_code = 200
        return jsonify(resposta)
    except Exception as error:
        status_code = 500
        logging.error(f"An error occurred: {error}")
    else:
        HTTP_REQUEST_COUNT.labels(request.method, '/api/senhas', status_code).inc()
        HTTP_REQUEST_LATENCY_SECONDS.labels(request.method, '/api/senhas', status_code).observe(time.time() - start_time)

@app.route('/metrics')
def metrics():
    return generate_latest()

if __name__ == '__main__':
    import logging
    logging.basicConfig(filename='error.log', level=logging.DEBUG)
    start_http_server(8088)
    app.run(debug=True)
