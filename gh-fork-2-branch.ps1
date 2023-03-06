# Set the GitHub repository
$repoOwner = "repo-owner"
$repoName = "repo-name"

# Set the GitHub username and access token for authentication
$username = "your-username"
$accessToken = "your-personal-access-token"

#############################################################################

# Clone the repository to the local directory
git clone https://${username}:${accessToken}@github.com/${repoOwner}/${repoName}.git

# Change to the local directory
cd $repoName

# Get a list of all the forks for the repository
$headers = @{
    Authorization="Bearer $accessToken";

}
$forks = (Invoke-WebRequest -Uri "https://api.github.com/repos/$repoOwner/$repoName/forks?per_page=100" -Method Get -Headers $headers -UseBasicParsing -ContentType "application/json; charset=utf-8").Content | ConvertFrom-Json

# Get a list of all branches in the repository
$branches = git branch -a | where { $_ -notmatch "main" }

foreach ($fork in $forks) {
    $newBranch = $fork.name
    $match = $false
    # Check if the branch already exists
    foreach  ($branch in $branches) {
        $branch = $branch -replace "remotes/origin/", ""
        $branch = $branch -replace "\s", ""
        if ($newBranch -eq $branch){
            echo "$newBranch already exists"
            $match = $true
            break
        }   
    }
    # Create branch if not exist
    if ($match -eq $false){
        echo "creating $newBranch"
        git checkout main
        git checkout -b $newBranch
        git push https://${username}:${accessToken}@github.com/${repoOwner}/${repoName}.git $newBranch
    }
}

