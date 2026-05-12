build:
	docker compose build

up:
	docker compose up -d

down:
	docker compose down

restart:
	docker compose down && docker compose up -d

logs:
	docker compose logs -f

ps:
	docker compose ps

test:
	curl http://localhost:8000/health

clean:
	docker compose down -v --rmi all

shell:
	docker exec -it statuspulse-app bash

db:
	docker exec -it statuspulse-postgres psql -U statuspulse -d statuspulse