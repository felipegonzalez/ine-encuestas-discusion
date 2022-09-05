data {
  int<lower=0> N;
  int<lower=0> num_secciones;
  int<lower=0> num_estratos;
  int<lower=0> num_estados;
  real gamma;
  real gamma_de;
  array[N] int y;
  array[N] int n;
  vector[N] ponderador;
  array[N] int estrato;
  array[N] int estado;
  array[N] int tipo_cred;
  array[N] int seccion;
  //array[N] real p_edad;
  array[num_secciones] int estrato_secc;
}

// The parameters accepted by the model. Our model
// accepts two parameters 'mu' and 'sigma'.
parameters {
  real beta;
  matrix[num_estratos, 2] beta_e;
  real beta_edad;
  //vector[num_estratos] beta_e;
  //vector[2] beta_tipo;
  vector[num_secciones] beta_raw;
  array[num_estratos] real<lower=0> sigma;
}

transformed parameters {
  vector[N] alpha;
  vector[num_secciones] beta_secc;
  
  for(j in 1:num_secciones){
    beta_secc[j] = beta_raw[j] * sigma[estrato_secc[seccion[j]]]; 
  }
  
  for(i in 1:N){
    //alpha[i] = beta + beta_e[estrato[i]] + beta_tipo[tipo_cred[i]] + beta_secc[seccion[i]]; 
    alpha[i] = beta + beta_e[estrato[i], tipo_cred[i]] +  beta_secc[seccion[i]];
    //  beta_edad * p_edad[i]   
  }
  
}

model {
  y ~ binomial_logit(n, alpha);
  beta ~ normal(gamma, gamma_de);
  to_vector(beta_e) ~ normal(0, 1);
  //beta_tipo ~ normal(0, 1);
  beta_raw ~ normal(0, 1);
  beta_edad ~ normal(0, 1);
  sigma ~ normal(0, 0.25);
}

generated quantities {
  vector[num_estados] total_estado;
  vector[num_estados] total_lista_estado;
  real total;
  real total_lista;
  real prop;
  vector[num_estados] prop_estado;
  array[N] int y_rep;
  
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
  for(i in 1:N){
    y_rep[i] = binomial_rng(n[i] , inv_logit(alpha[i]));
  }
}
