#!/bin/bash
# ============================================
# NGINX INITIALIZATION SCRIPT
# Cloud-init script for vm-altint-001
# Installs and configures Nginx web server
# with AltIntellect portfolio landing page
# Runs automatically on first VM boot
# ============================================

# Update package list and install Nginx
apt-get update -y
apt-get install -y nginx

# Start and enable Nginx on boot
systemctl start nginx
systemctl enable nginx

# Create custom portfolio landing page
cat > /var/www/html/index.html << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>AltIntellect Cloud Portfolio</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        h1 { color: #0078d4; }
        h2 { color: #333; }
        .badge {
            background-color: #0078d4;
            color: white;
            padding: 5px 10px;
            border-radius: 4px;
            margin: 5px;
            display: inline-block;
        }
        .resource {
            background-color: white;
            padding: 15px;
            margin: 10px 0;
            border-radius: 8px;
            border-left: 4px solid #0078d4;
        }
        .footer {
            margin-top: 40px;
            color: #666;
            font-style: italic;
        }
    </style>
</head>
<body>
    <h1>AltIntellect Cloud Portfolio</h1>
    <p>Senior Cloud Architect — Infrastructure as Code Demonstration</p>

    <h2>Technology Stack</h2>
    <span class="badge">Microsoft Azure</span>
    <span class="badge">Terraform</span>
    <span class="badge">GitHub Actions</span>
    <span class="badge">Ubuntu 22.04</span>
    <span class="badge">Nginx</span>

    <h2>Deployed Infrastructure</h2>
    <div class="resource">Resource Group: rg-altint-compute — Canada Central</div>
    <div class="resource">Virtual Network: vnet-altint-compute-001 — 10.1.0.0/16</div>
    <div class="resource">Virtual Machine: vm-altint-001 — Standard_B2als_v2</div>
    <div class="resource">Web Server: Nginx — Deployed via cloud-init</div>

    <h2>Architecture Principles</h2>
    <div class="resource">Everything as Code — No manual portal clicks</div>
    <div class="resource">Security First — NSG restricted to known IPs</div>
    <div class="resource">Automation — GitHub Actions CI/CD pipeline</div>

    <p class="footer">Deployed automatically via Terraform and GitHub Actions</p>
</body>
</html>
HTML

# Log completion
echo "Nginx initialization complete" >> /var/log/nginx-init.log