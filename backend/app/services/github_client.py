import httpx
from typing import Dict, Any, Optional

class GitHubClient:
    BASE_URL = "https://api.github.com"

    async def get_user_data(self, username: str) -> Optional[Dict[str, Any]]:
        async with httpx.AsyncClient() as client:
            try:
                # 1. Fetch Profile
                profile_resp = await client.get(f"{self.BASE_URL}/users/{username}")
                if profile_resp.status_code != 200:
                    return None
                
                # 2. Fetch Repos (Increased limit to 100 for better analysis)
                repos_resp = await client.get(
                    f"{self.BASE_URL}/users/{username}/repos?sort=updated&per_page=100"
                )
                repos_data = repos_resp.json() if repos_resp.status_code == 200 else []

                return {
                    "profile": profile_resp.json(),
                    "repos": repos_data
                }
            except Exception as e:
                print(f"GitHub API Error: {e}")
                return None