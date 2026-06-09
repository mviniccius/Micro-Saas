# Débito Técnico

## [AUTH-01] Autenticação JWT e controle de acesso por perfil

**Status:** Pendente  
**Prioridade:** Alta  
**Contexto:** Adiado para facilitar o desenvolvimento das sprints 3 e 4.

### O que precisa ser feito

1. **Rota `POST /auth/login`**
   - Receber `email` e `senha` do body
   - Buscar usuário no banco pelo email
   - Comparar senha com `bcrypt.compare()`
   - Retornar token JWT com `{ id, email, perfil_id }` e expiração de 8h

2. **Atualizar `POST /users`**
   - Passar `perfil_id` ao criar usuário
   - Fazer hash da senha com `bcrypt.hash()` antes de salvar

3. **Aplicar middlewares nas rotas protegidas**
   - `autenticar` — valida o token (já implementado em `middleware/autenticar.js`)
   - `autorizar(perfilId)` — valida o perfil (já implementado em `middleware/autorizar.js`)

4. **Seed dos perfis no banco**
   - `id_perfil = 1` → ADM (acesso total)
   - `id_perfil = 2` → FUNCIONARIO (acesso somente a `/pedidos`)

### Pacotes já instalados
- `jsonwebtoken@9.0.3`
- `bcrypt@6.0.0`

### Arquivos já criados
- `Back/middleware/autenticar.js`
- `Back/middleware/autorizar.js`
- `Back/.env` — contém `JWT_SECRET`
