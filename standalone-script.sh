#Delete specified files if they exist
for file in dependency.txt licenses.txt outdated-dependencies.txt sbom-result.txt trivy-vulnerabilities.txt formatted_dependencies.txt; do
    if [ -f "$file" ]; then
        echo "Deleting $file..."
        rm "$file"
    else
        echo "$file does not exist, skipping."
    fi
done
echo "Installing Trivy..."
INSTALL_DIR="$HOME/bin"
PROJECT_DIR=$(pwd)
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b $INSTALL_DIR v0.50.4
$INSTALL_DIR/trivy fs --scanners vuln --format table --output trivy-vulnerabilities.txt "$PROJECT_DIR"

apt-get update && apt-get install -y wget
wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list
mv prod.list /etc/apt/sources.list.d/microsoft-prod.list
apt-get update
apt-get install -y powershell
rm -rf prod.list
cd "$PROJECT_DIR"



rm -rf scripts
mkdir scripts 
wget https://raw.githubusercontent.com/the-psi/sbom/dotnet/scripts/dotnet-install.sh -P scripts 
wget https://raw.githubusercontent.com/the-psi/sbom/main/dotnet/scripts/get-details-1.sh -P scripts 
wget https://raw.githubusercontent.com/the-psi/sbom/main/dotnet/scripts/get-details-2.sh -P scripts 
wget https://raw.githubusercontent.com/the-psi/sbom/main/dotnet/scripts/merge-details.ps1 -P scripts

chmod +x ./scripts/dotnet-install.sh
chmod +x ./scripts/get-details-1.sh    
chmod +x ./scripts/get-details-2.sh  
chmod +x ./scripts/merge-details.ps1  
bash ./scripts/dotnet-install.sh
bash ./scripts/get-details-1.sh        
bash ./scripts/get-details-2.sh
pwsh ./scripts/merge-details.ps1 