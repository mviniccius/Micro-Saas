FLUTTER_APP=app_cliente
FLUTTER_PRESTADOR=app_prestador
FRONT_DIR=front
BACK_DIR=Back

.PHONY: up down logs flutter flutter-prestador front dev all stop run-back-log

# Sobe o backend (Docker)
up:
	docker compose -f $(BACK_DIR)/compose.yaml up -d
	@echo "Backend rodando em http://localhost:3000"

# Derruba o backend
down:
	docker compose -f $(BACK_DIR)/compose.yaml down

# Logs do backend
logs:
	docker compose -f $(BACK_DIR)/compose.yaml logs -f app

# Sobe o backend e já exibe os logs em tempo real
run-back-log:
	docker compose -f $(BACK_DIR)/compose.yaml up --build && \
	docker compose -f $(BACK_DIR)/compose.yaml logs -f app

# Roda o app Flutter no Chrome na porta 4200
flutter:
	cd $(FLUTTER_APP) && flutter run -d chrome --web-port 4200

# Roda o app Flutter do prestador no Chrome na porta 4201
flutter-prestador:
	cd $(FLUTTER_PRESTADOR) && flutter run -d chrome --web-port 4201

# Roda o front web (Vite)
front:
	cd $(FRONT_DIR) && npm run dev

# Sobe tudo: backend (Docker) + app_cliente + app_prestador
all: up
	@echo "Iniciando app_cliente (porta 4200)..."
	cd $(FLUTTER_APP) && flutter run -d chrome --web-port 4200 &
	@echo "Iniciando app_prestador (porta 4201)..."
	cd $(FLUTTER_PRESTADOR) && flutter run -d chrome --web-port 4201 &
	@echo ""
	@echo "Backend:       http://localhost:3000"
	@echo "App cliente:   http://localhost:4200"
	@echo "App prestador: http://localhost:4201"

# Derruba o backend e encerra os processos Flutter
stop:
	docker compose -f $(BACK_DIR)/compose.yaml down
	@pkill -f "flutter run" 2>/dev/null || true
	@echo "Tudo parado."

# Sobe tudo junto (backend + front web em paralelo, Flutter separado)
dev: up
	@echo "Iniciando front web..."
	cd $(FRONT_DIR) && npm run dev &
	@echo ""
	@echo "Para rodar o Flutter: make flutter"
	@echo "Para ver logs do backend: make logs"
