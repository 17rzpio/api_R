library(plumber)
library(DBI)
library(RPostgres)

# Abre uma conexão com o PostgreSQL
conectar <- function() {
  dbConnect(
    RPostgres::Postgres(),
    host = "localhost",
    port = 5432,
    dbname = "api_r",
    user = "postgres",
    password = "123456"
  )
}

# LISTAR — GET /usuarios
#* @get /usuarios
function() {
  con <- conectar()
  on.exit(dbDisconnect(con))

  dbGetQuery(con, "SELECT * FROM usuarios ORDER BY id")
}

# BUSCAR UM — GET /usuarios/1
#* @get /usuarios/<id>
function(id) {
  con <- conectar()
  on.exit(dbDisconnect(con))

  dbGetQuery(
    con,
    "SELECT * FROM usuarios WHERE id = $1",
    params = list(as.integer(id))
  )
}

#* @post /usuarios
#* @parser json
function(req) {
  dados <- req$body

  con <- conectar()
  on.exit(dbDisconnect(con))

  novo <- dbGetQuery(
    con,
    "INSERT INTO usuarios (nome, idade)
     VALUES ($1, $2)
     RETURNING id, nome, idade",
    params = list(dados$nome, as.integer(dados$idade))
  )

  list(mensagem = "Usuário criado", usuario = novo)
}

# ATUALIZAR — PUT /usuarios/1?nome=Ana&idade=21
#* @put /usuarios/<id>
function(id, nome, idade) {
  con <- conectar()
  on.exit(dbDisconnect(con))

  linhas <- dbExecute(
    con,
    "UPDATE usuarios
     SET nome = $1, idade = $2
     WHERE id = $3",
    params = list(nome, as.integer(idade), as.integer(id))
  )

  list(mensagem = "Usuário atualizado", alterados = linhas)
}

# EXCLUIR — DELETE /usuarios/1
#* @delete /usuarios/<id>
function(id) {
  con <- conectar()
  on.exit(dbDisconnect(con))

  linhas <- dbExecute(
    con,
    "DELETE FROM usuarios WHERE id = $1",
    params = list(as.integer(id))
  )

  list(mensagem = "Usuário excluído", removidos = linhas)
}