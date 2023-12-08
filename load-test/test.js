import http from "k6/http";

export const products = [
  '0PUK6V6EV0',
  '1YMWWN1N4O',
  '2ZYFJ3GM2N',
  '66VCHSJNUP',
  '6E92ZMYYFZ',
  '9SIQT8TOJO',
  'L9ECAV7KIM',
  'LS4PSXUNUM',
  'OLJCESPC7Z'
];

export const options = {
  scenarios: {
    index: {
      executor: "shared-iterations",
      exec: "index",
      vus: 80,
      iterations: 100,
    },
    currency: {
      executor: "shared-iterations",
      exec: "currency",
      vus: 20,
      iterations: 100,
    },
    browse_products: {
      executor: "shared-iterations",
      exec: "browse_products",
      vus: 20,
      iterations: 100,
    },
    view_cart: {
      executor: "shared-iterations",
      exec: "view_cart",
      vus: 20,
      iterations: 100,
    },
    add_cart: {
      executor: "shared-iterations",
      exec: "add_cart",
      vus: 20,
      iterations: 100,
    },
    checkout: {
      executor: "shared-iterations",
      exec: "checkout",
      vus: 20,
      iterations: 100,
    },
  },
};

export function index() {
  http.get('http://localhost:8080/');
}

export function currency() {
  const currencies = ['EUR', 'USD', 'JPY', 'CAD'];

  const payload = JSON.stringify({
    currency_code: currencies[Math.floor(Math.random() * currencies.length)]
  });

  const params = {
    headers: {
      "Content-Type": "application/json",
    },
  };

  http.post('http://localhost:8080/setCurrency', payload, params);
}

export function browse_products() {
  http.get('http://localhost:8080/product/' + products[Math.floor(Math.random() * products.length)]);
}

export function view_cart() {
  http.get('http://localhost:8080/cart');
}

export function add_cart() {
  const product = products[Math.floor(Math.random() * products.length)];
  const quantityRange = [1,2,3,4,5,6,7,8,9];

  http.get('http://localhost:8080/product/' + products[Math.floor(Math.random() * products.length)]);

  const payload = JSON.stringify({
    product_id: product,
    quantity: quantityRange[Math.floor(Math.random()*quantityRange.length)]
  });

  const params = {
    headers: {
      "Content-Type": "application/json",
    },
  };

  http.post('http://localhost:8080/cart', payload, params);
}

export function checkout() {
  add_cart()

  const payload = JSON.stringify({
    email: 'someone@example.com',
    street_address: '1600 Amphitheatre Parkway',
    zip_code: '94043',
    city: 'Mountain View',
    state: 'CA',
    country: 'United States',
    credit_card_number: '4432-8015-6152-0454',
    credit_card_expiration_month: '1',
    credit_card_expiration_year: '2039',
    credit_card_cvv: '672',
  });

  const params = {
    headers: {
      "Content-Type": "application/json",
    },
  };

  http.post('http://localhost:8080/cart/checkout', payload, params);
}