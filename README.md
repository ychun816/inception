
﹏𓃬_𓃮𓃮﹏𓃮﹏
🀄︎🀀🀁🀂🀃🀅🀇🀈🀉
🀢🀣🀤🀥🀦🀧🀨🀩🀐🀙

# Brief
𓃻 Brief for Total Newbs: 
https://hackmd.io/@QBrv51OvRPqs9dJjL2YIig/HkWxR-JExe

𓃻 Set up Online Virtual Server(VPS) instead of local virtual machine :
https://github.com/ychun816/inception-VPS-setup-tutorial

# Set-up
Dockerfile :
https://hackmd.io/@QBrv51OvRPqs9dJjL2YIig/BJE4fQvVlx

Docker-Compose (EDITINGGG) : 


# Containers (Mandotary)
🀢 Nginx tests+explains :
https://hackmd.io/@QBrv51OvRPqs9dJjL2YIig/rk2Jbr24xe

🀨 database / mariaDB :
https://hackmd.io/QYAwoSX0THiijO70dljNgQ?both

🀦 Wordpress (EDITINGGG) :

🀣 Bonus: redis & adminer :
https://hackmd.io/IHK8axy8SpugLSENZhLPOg

# Summary
🀐 Total Project summary (EDITINGGG) :
https://hackmd.io/@QBrv51OvRPqs9dJjL2YIig/r1d5G7Nrlx

🀩 Tests for each Container + Important Concept briefs :
https://hackmd.io/@QBrv51OvRPqs9dJjL2YIig/Hyws9Q_Sxg

=====================================================


# 🧠 INCEPTION
## Docker, System Administration, Virtualization

﹏𓃬_𓃮𓃮﹏𓃮﹏ 🀄︎🀀🀁🀂🀃🀅🀇🀈🀉 🀢🀣🀤🀥🀦🀧🀨🀩🀐🀙

---

## 📘 Table of Contents
- [About](#about)
- [Resources & References](#resources--references)
- [Setup Overview](#setup-overview)
- [Container Architecture](#container-architecture)
- [ASCII Network Diagram](#ascii-network-diagram)
- [Key Concepts Learned](#key-concepts-learned)
- [Skills Developed](#skills-developed)
- [42 School Standards](#42-school-standards)
- [Contact](#contact)

---

## 🧩 About

**Inception** is a 42 School DevOps project that introduces system administration, virtualization, and container orchestration through **Docker** and **Docker Compose**.  

You must create and configure multiple containers—each serving a specific role—while managing networks, persistent volumes, and inter-container communication securely.

This project focuses on:
- Building reproducible infrastructure entirely from Dockerfiles (no pre-built images)
- Understanding container lifecycle and isolation
- Configuring secure communication between services
- Managing data persistence and orchestration with Docker Compose

---

## 📚 Resources & References

> These are your main learning and reference materials used during project development.

- 🌐 **Project Brief for Total Newbs:**  
  [https://hackmd.io/@QBrv51OvRPqs9dJjL2YIig/HkWxR-JExe](https://hackmd.io/@QBrv51OvRPqs9dJjL2YIig/HkWxR-JExe)

- ☁️ **Set up Online VPS (instead of local VM):**  
  [Inception VPS Setup Tutorial](https://github.com/ychun816/inception-VPS-setup-tutorial)

- ⚙️ **Dockerfile Reference:**  
  [https://hackmd.io/@QBrv51OvRPqs9dJjL2YIig/BJE4fQvVlx](https://hackmd.io/@QBrv51OvRPqs9dJjL2YIig/BJE4fQvVlx)

- 🐋 **Docker Compose Notes (Editing in Progress)**

### Containers Documentation
- 🀢 **Nginx:** [Tests & Explanations](https://hackmd.io/@QBrv51OvRPqs9dJjL2YIig/rk2Jbr24xe)  
- 🀨 **MariaDB:** [DB Setup & Logic](https://hackmd.io/QYAwoSX0THiijO70dljNgQ?both)  
- 🀦 **WordPress:** *(Editing in progress)*  
- 🀣 **Redis & Adminer (Bonus):** [Redis / Adminer Notes](https://hackmd.io/IHK8axy8SpugLSENZhLPOg)

### Summary & Testing
- 🀐 **Total Project Summary:** *(Editing in progress)*  
- 🀩 **Tests for Containers & Concept Notes:**  
  [https://hackmd.io/@QBrv51OvRPqs9dJjL2YIig/Hyws9Q_Sxg](https://hackmd.io/@QBrv51OvRPqs9dJjL2YIig/Hyws9Q_Sxg)

---

## ⚙️ Setup Overview

Each service is built **from scratch** using a dedicated Dockerfile.  
No external pre-built images are used (only Debian base).

### Mandatory Containers
- 🀢 **Nginx** – Reverse proxy & SSL termination  
- 🀨 **MariaDB** – Database backend for WordPress  
- 🀦 **WordPress (PHP-FPM)** – Main application layer  

### Bonus Containers
- 🀣 **Redis** – Caching layer for WordPress  
- 🀩 **Adminer** – Lightweight web-based DB management tool

### Network & Persistence
- All containers communicate through a private **bridge network**
- Persistent data stored in named **volumes** for WordPress and MariaDB

---

## 🏗 Container Architecture

| Container | Role | Exposed Port | Data Persistence | Key Notes |
|------------|------|---------------|------------------|------------|
| **Nginx** | Reverse proxy with SSL | 443 / 80 | Mounted certs & configs | Routes traffic to WordPress |
| **WordPress (PHP-FPM)** | Application layer | 9000 (internal) | WordPress content volume | Uses env vars for DB connection |
| **MariaDB** | Database | 3306 (internal) | MySQL data volume | Secure access via internal network |
| **Redis** | Caching | 6379 (internal) | N/A | Improves WP performance |
| **Adminer** | Database web UI | 8080 (external) | N/A | Optional, for debugging |

---

## 🕸 Network Diagram

### 🧠 Inception Network Topology

```text
┌──────────────────────────────────────────────────────────────────────────────┐
│                                🌍 CLIENT / USER                              │
│──────────────────────────────────────────────────────────────────────────────│
│  Access via → https://your-domain.com  🔒 (Port 443 / SSL)                   │
└──────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
        ┌──────────────────────────────────────────────────────────────┐
        │                         🀢 NGINX                             │
        │──────────────────────────────────────────────────────────────│
        │ • Reverse proxy + SSL termination                            │
        │ • Routes: 443 → WordPress:9000                               │
        │ • Redirects HTTP (80) → HTTPS (443)                          │
        │ • Volumes:                                                   │
        │     ↳ ./requirements/nginx/conf   → /etc/nginx/conf.d        │
        │     ↳ ./requirements/nginx/certs  → /etc/nginx/certs         │
        │ • Connected to internal Docker bridge network                │
        └───────────────┬──────────────────────────────────────────────┘
                        │
                        ▼
        ┌──────────────────────────────────────────────────────────────┐
        │                        🀦 WORDPRESS                           │
        │──────────────────────────────────────────────────────────────│
        │ • PHP-FPM container (runs WordPress app)                     │
        │ • Listens on port 9000 (internal only)                       │
        │ • Talks to: MariaDB (3306), Redis (6379)                     │
        │ • Volumes:                                                   │
        │     ↳ ./requirements/wordpress → /var/www/html               │
        │     ↳ ./data/wordpress       → /var/www/html/wp-content      │
        │ • Env vars: DB_NAME, DB_USER, DB_PASS, REDIS_HOST            │
        └───────────────┬──────────────────────────────────────────────┘
                        │
                        ▼
        ┌──────────────────────────────────────────────────────────────┐
        │                        🀨 MARIADB                             │
        │──────────────────────────────────────────────────────────────│
        │ • SQL database backend (stores WordPress data)               │
        │ • Port: 3306 (internal only)                                 │
        │ • Volumes:                                                   │
        │     ↳ ./data/mariadb → /var/lib/mysql                        │
        │ • Env vars:                                                  │
        │     ↳ MYSQL_ROOT_PASSWORD, MYSQL_DATABASE                    │
        │     ↳ MYSQL_USER, MYSQL_PASSWORD                             │
        └───────────────┬──────────────────────────────────────────────┘
                        │
                        ▼
        ┌──────────────────────────────────────────────────────────────┐
        │                      🧱 PERSISTENT VOLUMES                    │
        │──────────────────────────────────────────────────────────────│
        │ • ./data/wordpress → stores website content                  │
        │ • ./data/mariadb  → stores database data                     │
        │ • Ensures data survives container restarts                   │
        └───────────────┬──────────────────────────────────────────────┘
                        │
                        ▼
        ┌──────────────────────────────────────────────────────────────┐
        │                  🀣🀩 BONUS CONTAINERS                        │
        │──────────────────────────────────────────────────────────────│
        │ 🀣 REDIS   → caching layer (port 6379 internal)              │
        │ 🀩 ADMINER → lightweight DB web UI (port 8080 → host mapped) │
        │ Both linked via same docker network for internal access.     │
        └──────────────────────────────────────────────────────────────┘
```
# **Legend**
- 🔒  SSL handled by NGINX  
- 🧱  Persistent volume  
- 🀢  Reverse proxy / entrypoint  
- 🀦  Application (WordPress)  
- 🀨  Database (MariaDB)  
- 🀣  Cache (Redis)  
- 🀩  Database Admin GUI (Adminer)


# **Flow Summary**
1️⃣ Client sends HTTPS request → NGINX (SSL termination)  
2️⃣ NGINX proxies PHP requests → WordPress (port 9000)  
3️⃣ WordPress queries data → MariaDB via internal bridge  
4️⃣ Redis accelerates caching for performance  
5️⃣ Adminer allows DB inspection via secure mapped port  
6️⃣ All data persists via mounted volumes under `./data`


# Key Concepts Learned
- Containerization Fundamentals: Dockerfile creation, dependency isolation
- Networking: Bridge networks, port mapping, internal service routing
- Data Persistence: Bind mounts and named volumes for resilient data
- Security: SSL setup, least privilege configurations
- Automation: Docker Compose orchestration and lifecycle control
- Debugging: Log inspection, health checks, rebuild automation

# Skills Developed
- Mastery of Docker & Compose fundamentals
- Understanding of Linux system administration
- Secure web service deployment
- Environment configuration via .env
- Infrastructure-as-code mindset
- Performance tuning with Redis caching



