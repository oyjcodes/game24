# Simple GitHub Pages Deployment Script for 24 Points Game
param(
    [string]$GitHubUsername = "oyjcodes",
    [string]$RepoName = "game24",
    [string]$Branch = "main",
    [string]$CommitMessage = "Deploy 24 points game to GitHub Pages"
)

Write-Host "🚀 Deploying 24 Points Game to GitHub Pages" -ForegroundColor Green
Write-Host "Repository: https://github.com/${GitHubUsername}/${RepoName}.git" -ForegroundColor Yellow
Write-Host "Branch: ${Branch}" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Cyan

# Check if in correct directory
$currentPath = Get-Location
$gameFile = Join-Path $currentPath "24-points-game.html"
if (!(Test-Path $gameFile)) {
    Write-Host "❌ Please run this script from the demo directory" -ForegroundColor Red
    Write-Host "Current directory: $currentPath" -ForegroundColor Yellow
    exit 1
}

# Initialize git repo if needed
if (!(Test-Path ".git")) {
    Write-Host "📝 Initializing Git repository..." -ForegroundColor Blue
    git init
    git checkout -b $Branch
}

# Set remote origin
Write-Host "🔗 Setting up remote repository..." -ForegroundColor Blue
$remoteUrl = "https://github.com/${GitHubUsername}/${RepoName}.git"
try {
    git remote remove origin 2>$null
} catch {
    # Remote doesn't exist, that's fine
}
git remote add origin $remoteUrl

# Switch to correct branch
$currentBranch = git branch --show-current 2>$null
if ($currentBranch -ne $Branch) {
    Write-Host "🔀 Switching to ${Branch} branch..." -ForegroundColor Blue
    try {
        git checkout $Branch 2>$null
    } catch {
        git checkout -b $Branch
    }
}

# Add and commit files
Write-Host "📦 Adding files..." -ForegroundColor Blue
git add .

$status = git status --porcelain
if ($status) {
    Write-Host "💾 Committing changes..." -ForegroundColor Blue
    git commit -m $CommitMessage
    Write-Host "✅ Commit successful" -ForegroundColor Green
} else {
    Write-Host "ℹ️  No changes to commit" -ForegroundColor Yellow
}

# Push to GitHub
Write-Host "📤 Pushing to GitHub..." -ForegroundColor Blue
try {
    git push -u origin $Branch
    Write-Host "✅ Push successful!" -ForegroundColor Green

    Write-Host "" -ForegroundColor White
    Write-Host "🌐 Your game will be available at:" -ForegroundColor Cyan
    Write-Host "https://${GitHubUsername}.github.io/${RepoName}/" -ForegroundColor White
    Write-Host "" -ForegroundColor White
    Write-Host "📋 Next steps:" -ForegroundColor Cyan
    Write-Host "1. Go to: https://github.com/${GitHubUsername}/${RepoName}/settings/pages" -ForegroundColor White
    Write-Host "2. Set source to '${Branch}' branch and '/ (root)' folder" -ForegroundColor White
    Write-Host "3. Save and wait a few minutes" -ForegroundColor White
    Write-Host "" -ForegroundColor White
    Write-Host "🎉 Deployment complete! Share with your friends!" -ForegroundColor Green
} catch {
    Write-Host "❌ Push failed. Please check:" -ForegroundColor Red
    Write-Host "1. GitHub username is correct" -ForegroundColor Yellow
    Write-Host "2. Repository exists" -ForegroundColor Yellow
    Write-Host "3. You have push permissions" -ForegroundColor Yellow
    Write-Host "4. Network connection is working" -ForegroundColor Yellow
    exit 1
}
