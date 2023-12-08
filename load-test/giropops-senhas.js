import http from "k6/http";

export const options = {
  scenarios: {
    index: {
      executor: "constant-arrival-rate",
      exec: "index",
      rate: 1000,
      timeUnit: '1m',
      duration: '5m',
      preAllocatedVUs: 10,
      maxVUs: 15
    },
    generate_pwd: {
      executor: "constant-arrival-rate",
      exec: "generate_pwd",
      rate: 1000,
      timeUnit: '1m',
      duration: '5m',
      preAllocatedVUs: 10,
      maxVUs: 15
    },
    get_pwd: {
      executor: "constant-arrival-rate",
      exec: "get_pwd",
      rate: 1000,
      timeUnit: '1m',
      duration: '5m',
      preAllocatedVUs: 10,
      maxVUs: 15
    },
  },
};

export function index() {
  http.get('http://ac2f0e968a0a6435980c515787d8aa5b-27337165031ee7a9.elb.us-east-1.amazonaws.com/');
}

export function generate_pwd() {
  const min = 20;
  const max = 50;
  const random = (min, max) => Math.floor(Math.random() * (max - min)) + min;
  const payload = JSON.stringify({
    tamanho: random,
    incluir_numeros: true,
    incluir_caracteres_especiais: true
  });

  const params = {
    headers: {
      "Content-Type": "application/json",
    },
  };

  http.post('http://ac2f0e968a0a6435980c515787d8aa5b-27337165031ee7a9.elb.us-east-1.amazonaws.com/api/gerar-senha', payload, params);
}

export function get_pwd() {
  http.get('http://ac2f0e968a0a6435980c515787d8aa5b-27337165031ee7a9.elb.us-east-1.amazonaws.com/api/senhas');
}