data {
  int<lower=0> N;
  int<lower=0> num_secciones;
  int<lower=0> num_estratos;
  int<lower=0> num_estados;
  real gamma;
  real gamma_de;
  //array[N] int y;
  array[N] int n;
  vector[N] ponderador;
  array[N] int estrato;
  array[N] int estado;
  array[N] int tipo_cred;
  array[N] int seccion;
  array[num_secciones] int estrato_secc;
}

// The parameters accepted by the model. Our model
// accepts two parameters 'mu' and 'sigma'.
parameters {
  //real beta;
  //matrix[num_estratos, 2] beta_e;
  //vector[num_estratos] beta_e;
  //vector[2] beta_tipo;
  //vector[num_secciones] beta_raw;
  //array[num_secciones] real<lower=0> sigma;
}

transformed parameters {
  //vector[N] alpha;
  //vector[num_secciones] beta_secc;
  
  //for(j in 1:num_secciones){
 //   beta_secc[j] = beta_raw[j] * sigma[estrato_secc[seccion[j]]]; 
  //}
  
  //for(i in 1:N){
    //alpha[i] = beta + beta_e[estrato[i]] + beta_tipo[tipo_cred[i]] + beta_secc[seccion[i]]; 
    //alpha[i] = beta + beta_e[estrato[i], tipo_cred[i]] + beta_secc[seccion[i]]; 
  //}
  
}

model {
  //y ~ binomial_logit(n, alpha);
  //beta ~ normal(gamma, gamma_de);
  //to_vector(beta_e) ~ normal(0, 2);
  //beta_tipo ~ normal(0, 1);
  //beta_raw ~ normal(0, 1);
  //sigma ~ normal(0, 1);
}

generated quantities {
  vector[num_estados] total_estado;
  vector[num_estados] total_lista_estado;
  real total;
  real total_lista;
  real prop;
  vector[num_estados] prop_estado;
  real beta;
  vector[num_secciones] beta_raw;
  array[num_estratos] real<lower=0> sigma;
  matrix[num_estratos, 2] beta_e;
  array[N] int y;
  vector[N] alpha;
  
  beta = normal_rng(gamma, gamma_de);
  for(j in 1:num_secciones){
    beta_raw[j] = normal_rng(0, 1);
  }
  for(k in 1:num_estratos){
    sigma[k] = abs(normal_rng(0, 1));
  }
  for(i in 1:num_estratos){
    for(j in 1:2){
      beta_e[i, j] = normal_rng(0, 1.5);
    }
  }
  for(i in 1:N){
        alpha[i] = beta + beta_e[estrato[i], tipo_cred[i]] + beta_raw[seccion[i]]*sigma[estrato_secc[seccion[i]]]; 
        y[i] = binomial_rng(n[i], inv_logit(alpha[i]));
  }
  total = 0;
  total_lista = 0;
  for(k in 1:num_estados){
    total_estado[k] = 0;
    total_lista_estado[k] = 0;
  }
  for(i in 1:N){
    total += ponderador[i] * inv_logit(alpha[i]);
    total_lista += ponderador[i];
    total_estado[estado[i]] += ponderador[i] * inv_logit(alpha[i]);
    total_lista_estado[estado[i]] += ponderador[i];
  }
  for(k in 1:num_estados){
    prop_estado[k] = total_estado[k] / total_lista_estado[k];
  }
  prop = total / total_lista;
}
