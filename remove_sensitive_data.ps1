# Script to remove google-services.json from Git history
# WARNING: This rewrites git history. Make sure you have a backup!

Write-Host "Removing google-services.json from Git history..." -ForegroundColor Yellow
Write-Host "This will rewrite your Git history!" -ForegroundColor Red
Write-Host ""

$response = Read-Host "Do you want to continue? (yes/no)"
if ($response -ne "yes") {
    Write-Host "Operation cancelled." -ForegroundColor Yellow
    exit
}

# Remove the file from Git history using git filter-branch
git filter-branch --force --index-filter `
    "git rm --cached --ignore-unmatch android/app/google-services.json" `
    --prune-empty --tag-name-filter cat -- --all

Write-Host ""
Write-Host "File removed from history. Now force push to remote:" -ForegroundColor Green
Write-Host "git push origin --force --all" -ForegroundColor Cyan
Write-Host ""
Write-Host "WARNING: This will overwrite the remote repository!" -ForegroundColor Red
