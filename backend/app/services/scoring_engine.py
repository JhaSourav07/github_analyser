from typing import Dict, Any, List

class ScoringEngine:
    
    def calculate_score(self, profile: Dict[str, Any], repos: List[Dict[str, Any]]) -> Dict[str, Any]:
        """
        Calculates a 0-100 score based on engineering metrics.
        """
        score = 0
        
        # Initialize details with safe defaults
        details = {
            "repo_count": len(repos),
            "followers": profile.get("followers", 0),
            "original_repos": 0,
            "forked_repos": 0,
            "stars_earned": 0,
            "has_bio": False
        }

        # --- PRE-PROCESSING ---
        original_repos = [r for r in repos if not r.get('fork')]
        details['original_repos'] = len(original_repos)
        details['forked_repos'] = len(repos) - len(original_repos)
        details['stars_earned'] = sum(r.get('stargazers_count', 0) for r in repos)
        details['has_bio'] = bool(profile.get('bio'))

        # --- METRIC 1: Engineering Maturity (Weight: 35%) ---
        if len(original_repos) > 10:
            score += 30
        elif len(original_repos) > 5:
            score += 20
        elif len(original_repos) > 0:
            score += 10

        # --- METRIC 2: Impact & Recognition (Weight: 25%) ---
        if details['stars_earned'] > 50:
            score += 25
        elif details['stars_earned'] > 10:
            score += 15
        elif details['stars_earned'] > 0:
            score += 5

        # --- METRIC 3: Professionalism (Weight: 25%) ---
        if details['has_bio']:
            score += 10
        if profile.get('company') or profile.get('location'):
            score += 10
            
        # --- METRIC 4: Consistency (Weight: 15%) ---
        if details['followers'] > 20:
            score += 25
        elif details['followers'] > 5:
            score += 15

        # Cap score at 100
        final_score = min(score, 100)

        return {
            "score": final_score,
            "grade": self._get_grade(final_score),
            "summary": self._get_summary(final_score),
            "details": details
        }

    def _get_grade(self, score: int) -> str:
        if score >= 90: return "A+"
        if score >= 80: return "A"
        if score >= 70: return "B"
        if score >= 50: return "C"
        return "D"

    def _get_summary(self, score: int) -> str:
        if score >= 80:
            return "Strong engineering profile with proven impact."
        if score >= 50:
            return "Solid foundation, but needs more original work."
        return "Early stage profile. Focus on building original projects."