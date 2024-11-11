#!/bin/bash
sudo apt-get update -y && sudo apt-get install -y apache2 sysstat curl jq

# Get instance metadata
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
META_URL="http://169.254.169.254/latest/meta-data"
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s $META_URL/instance-id)
INSTANCE_TYPE=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s $META_URL/instance-type)
PUBLIC_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s $META_URL/public-ipv4)
PRIVATE_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s $META_URL/local-ipv4)
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
MEMORY_USAGE=$(free | awk '/Mem:/ {print int($3/$2 * 100)}')
AVAILABILITY_ZONE=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s $META_URL/placement/availability-zone)
REGION=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s $META_URL/placement/region)

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AWS EC2 Dashboard</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --aws-dark: #232f3e;
            --aws-orange: #ff9900;
            --aws-blue: #007bff;
            --aws-green: #16da81;
        }

        body {
            margin: 0;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto;
            background: linear-gradient(135deg, var(--aws-dark) 0%, #0f1924 100%);
            color: white;
            min-height: 100vh;
        }

        /* Animated Background */
        .background {
            position: fixed;
            width: 100vw;
            height: 100vh;
            z-index: -1;
            background: 
                radial-gradient(2px 2px at 20px 30px, #ff9900, rgba(0,0,0,0)),
                radial-gradient(2px 2px at 40px 70px, #ffffff, rgba(0,0,0,0)),
                radial-gradient(2px 2px at 50px 160px, #ff9900, rgba(0,0,0,0));
            background-size: 200px 200px;
            animation: stars 8s linear infinite;
        }

        /* Main Container */
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 2rem;
        }

        /* Header Component */
        .header {
            text-align: center;
            margin-bottom: 2rem;
            animation: slideDown 0.5s ease;
        }

        .aws-logo {
            color: var(--aws-orange);
            font-size: 3rem;
            animation: pulse 2s infinite;
        }

        /* Status Badge Component */
        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            background: rgba(22, 218, 129, 0.1);
            padding: 0.5rem 1rem;
            border-radius: 20px;
            margin-top: 1rem;
            animation: fadeIn 1s ease;
        }

        /* Grid Layout */
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.5rem;
            animation: fadeIn 0.5s ease;
        }

        /* Card Component */
        .card {
            background: rgba(255,255,255,0.1);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 1.5rem;
            border: 1px solid rgba(255,255,255,0.1);
            transition: all 0.3s ease;
            animation: slideUp 0.5s ease;
        }

        .card:hover {
            transform: translateY(-5px);
            border-color: var(--aws-orange);
            box-shadow: 0 10px 20px rgba(0,0,0,0.2);
        }

        /* Metric Component */
        .metric {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding: 1rem;
            background: rgba(0,0,0,0.2);
            border-radius: 10px;
            margin-bottom: 1rem;
            transition: all 0.3s ease;
        }

        .metric:hover {
            background: rgba(255,153,0,0.1);
        }

        /* Progress Bar Component */
        .progress-wrapper {
            flex: 1;
            margin-left: 1rem;
        }

        .progress-bar {
            height: 8px;
            background: rgba(255,255,255,0.1);
            border-radius: 4px;
            overflow: hidden;
            position: relative;
        }

        .progress-value {
            height: 100%;
            background: linear-gradient(90deg, var(--aws-orange), #ff5500);
            border-radius: 4px;
            transition: width 1s ease;
        }

        /* Animations */
        @keyframes stars {
            0% { background-position: 0 0; }
            100% { background-position: 0 200px; }
        }

        @keyframes pulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.05); }
        }

        @keyframes slideDown {
            from { transform: translateY(-20px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }

        @keyframes slideUp {
            from { transform: translateY(20px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        /* Add to your existing styles section */
        .metric i.fa-map-marker-alt,
        .metric i.fa-location-dot {
            color: var(--aws-orange);
            font-size: 1.2rem;
            width: 24px;
            text-align: center;
        }

        .metric:hover i {
            transform: scale(1.1);
            transition: transform 0.3s ease;
        }
    </style>
</head>
<body>
    <!-- Animated Background -->
    <div class="background"></div>

    <div class="container">
        <!-- Header Component -->
        <div class="header">
            <i class="fab fa-aws aws-logo"></i>
            <h1>EC2 Instance Dashboard</h1>
            <div class="status-badge">
                <i class="fas fa-circle" style="color: var(--aws-green)"></i>
                Running
            </div>
        </div>

        <!-- Main Grid -->
        <div class="grid">
            <!-- Instance Info Card -->
            <div class="card">
                <h2><i class="fas fa-server"></i> Instance Details</h2>
                <div class="metric">
                    <i class="fas fa-fingerprint"></i>
                    <div>
                        <strong>Instance ID</strong>
                        <div>${INSTANCE_ID}</div>
                    </div>
                </div>
                <div class="metric">
                    <i class="fas fa-microchip"></i>
                    <div>
                        <strong>Instance Type</strong>
                        <div>${INSTANCE_TYPE}</div>
                    </div>
                </div>
                <div class="metric">
                    <i class="fas fa-map-marker-alt"></i>
                    <div>
                        <strong>Region</strong>
                        <div>${REGION}</div>
                    </div>
                </div>
                <div class="metric">
                    <i class="fas fa-location-dot"></i>
                    <div>
                        <strong>Availability Zone</strong>
                        <div>${AVAILABILITY_ZONE}</div>
                    </div>
                </div>
            </div>

            <!-- System Metrics Card -->
            <div class="card">
                <h2><i class="fas fa-chart-line"></i> System Metrics</h2>
                <div class="metric">
                    <i class="fas fa-microchip"></i>
                    <div class="progress-wrapper">
                        <div>CPU Usage</div>
                        <div class="progress-bar">
                            <div class="progress-value" style="width: ${CPU_USAGE}%"></div>
                        </div>
                        <div>${CPU_USAGE}%</div>
                    </div>
                </div>
                <div class="metric">
                    <i class="fas fa-memory"></i>
                    <div class="progress-wrapper">
                        <div>Memory Usage</div>
                        <div class="progress-bar">
                            <div class="progress-value" style="width: ${MEMORY_USAGE}%"></div>
                        </div>
                        <div>${MEMORY_USAGE}%</div>
                    </div>
                </div>
            </div>

            <!-- Network Card -->
            <div class="card">
                <h2><i class="fas fa-network-wired"></i> Network</h2>
                <div class="metric">
                    <i class="fas fa-globe"></i>
                    <div>
                        <strong>Public IP</strong>
                        <div>${PUBLIC_IP}</div>
                    </div>
                </div>
                <div class="metric">
                    <i class="fas fa-network-wired"></i>
                    <div>
                        <strong>Private IP</strong>
                        <div>${PRIVATE_IP}</div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Auto refresh
        setInterval(() => window.location.reload(), 60000);

        // Animate metrics on load
        document.querySelectorAll('.progress-value').forEach(bar => {
            bar.style.width = '0%';
            setTimeout(() => {
                bar.style.width = bar.getAttribute('data-value') + '%';
            }, 500);
        });
    </script>
</body>
</html>
EOF

sudo systemctl restart apache2