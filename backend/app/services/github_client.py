import httpx
from typing import Dict, Any, Optional

class GitHubClient:
    BASE_URL = "https://api.github.com"

    async def get_user_data(self, username: str) -> Optional[Dict[str, Any]]:
        """
        Fetches GitHub data asynchronously.
        """
        async with httpx.AsyncClient() as client:
            try:
                # 1. Fetch Profile
                profile_resp = await client.get(f"{self.BASE_URL}/users/{username}")
                if profile_resp.status_code != 200:
                    return None
                
                # 2. Fetch Repositories (Limit to 50 for performance)
                repos_resp = await client.get(
                    f"{self.BASE_URL}/users/{username}/repos?sort=updated&per_page=50"
                )
                repos_data = repos_resp.json() if repos_resp.status_code == 200 else []

                return {
                    "profile": profile_resp.json(),
                    "repos": repos_data
                }
            except Exception as e:
                print(f"GitHub API Error: {e}")
                return None