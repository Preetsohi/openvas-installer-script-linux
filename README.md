# openvas-installer-script-linux
Automated OpenVAS installation script with troubleshooting and validation
OpenVAS Automated Docker Installer + Troubleshooting Script

A fully automated OpenVAS (Greenbone Vulnerability Scanner) installation script for Kali Linux & Ubuntu, packaged with built-in validation checks, permissions fixes, cleanup utilities, and troubleshooting logic to ensure reliable installation without repeated reinstall attempts.

This project provides:

🚀 One-click OpenVAS installation using Docker
🔄 Automatic container validation (health, restart-loop detection, port check)
🛠 Auto-fix for permission issues on /opt/openvas-data
🧹 Cleanup script to remove old/failed OpenVAS installations
♻️ Optional systemd service for auto-start on reboot
📌 Fully commented Bash script (openvas.sh) for reuse & team sharing

📂 Repository Contents
openvas-installer/

│
├── openvas.sh          
├── README.md           
└── LICENSE (optional)  

⭐ Features
✔ Automated Fresh Installation
Creates required directories
Sets correct permissions
Launches Docker container
Applies reliable startup parameters (--privileged, --shm-size, volume mapping)

✔ Built-In Validation
The script automatically verifies:

Check	Purpose
Docker is installed, ensuring environment readiness
Directory exists	/opt/openvas-data
Permissions	Avoid “database not initialised” problems
Container health	Detect restart loops
Port 8080 open. Confirm UI accessibility
✔ Automatic Troubleshooting

Fixes issues such as:

❌ “Container is restarting, wait until running”
❌ Empty /opt/openvas-data
❌ “database permissions incorrect”
❌ Healthcheck failures
❌ Reinstallation conflicts (container name already exists)

✔ Cleanup Utility

Runs with:
bash openvas.sh clean

Removes:
Old OpenVAS containers
Old Docker volumes
Old /opt/openvas-data directory
✔ Auto-Start on System Reboot
Optional one-line command to enable:
docker update --restart=unless-stopped openvas

🚀 How to Use
1️⃣ Download Script

If using the GitHub website:
Click Download raw file for openvas.sh.

If using CLI:
wget https://raw.githubusercontent.com/<your-username>/openvas-installer/main/openvas.sh
chmod +x openvas.sh

2️⃣ Run Installation
sudo bash openvas.sh

The script will:
Clean environment
Prepare directories
Launch container
Run health checks
Print login credentials
Confirm web UI availability

3️⃣ Login to OpenVAS UI

Open browser:

👉 http://localhost:8080
👉 or http://<your-local-ip>:8080

Default user: admin
Password: (set in your script)
♻️ Auto-start on Reboot (Optional)

Run:
sudo docker update --restart=unless-stopped openvas
This ensures OpenVAS starts automatically after a system reboot.

🧹 Clean Everything (Reset Installation)
sudo bash openvas.sh clean

This removes: openvas container

docker volume
/opt/openvas-data directory

leftover configs

Useful when the container is stuck in a restarting loop.

🧪 Troubleshooting Guide
🔹 Container stuck in restarting

Run:
docker logs openvas

Then use:
sudo bash openvas.sh clean
sudo bash openvas.sh

🔹 Port 8080 not opening

Check:
sudo lsof -i :8080

🔹 Database issues (pg_wal, PG_VERSION missing)

Reset permissions:
sudo chmod -R 755 /opt/openvas-data

✨ Author
Harpreet Singh Sohi
Security Researcher & Cloud Security Specialist
Net Solutions
