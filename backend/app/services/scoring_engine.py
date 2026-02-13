from typing import Dict, Any, List
from datetime import datetime

class ScoringEngine:
    
    def calculate_score(self, profile: Dict[str, Any], repos: List[Dict[str, Any]]) -> Dict[str, Any]:
        """
        Analyzes profile based on:
        1. Documentation (READMEs/Descriptions)
        2. Code Structure (Language diversity/completeness)
        3. Activity Consistency
        4. Impact (Stars/Forks)
        """
        score = 0
        strengths = []
        weaknesses = []
        suggestions = []
        
        # --- 1. DATA PRE-PROCESSING ---
        total_repos = len(repos)
        original_repos = [r for r in repos if not r.get('fork')]
        forked_repos = [r for r in repos if r.get('fork')]
        
        # Calculate Fork Ratio
        fork_ratio = len(forked_repos) / total_repos if total_repos > 0 else 0
        
        # Check Descriptions (Proxy for README/Documentation in MVP)
        repos_with_desc = [r for r in original_repos if r.get('description')]
        desc_ratio = len(repos_with_desc) / len(original_repos) if original_repos else 0
        
        # Check Stars
        total_stars = sum(r.get('stargazers_count', 0) for r in repos)
        
        # Check Recent Activity (Last 6 months)
        active_repos = 0
        current_year = datetime.now().year
        for r in original_repos:
            updated_at = r.get('updated_at', '')[:4] # Just check year for simplicity
            if str(current_year) in updated_at or str(current_year - 1) in updated_at:
                active_repos += 1

        # --- 2. SCORING LOGIC (The "Algorithm") ---
        
        # A. Originality (Max 30 pts)
        if total_repos == 0:
            weaknesses.append("Empty Portfolio: No public repositories found.")
            suggestions.append("Initialize a repository and push your first project.")
        elif fork_ratio > 0.7:
            score += 5
            weaknesses.append("Copycat Profile: High ratio of forked repositories.")
            suggestions.append("Archive unused forks and focus on original projects.")
        elif len(original_repos) > 5:
            score += 30
            strengths.append("Strong Maker Mindset: High volume of original work.")
        else:
            score += 15
            suggestions.append("Build more original projects to showcase your skills.")

        # B. Documentation & Professionalism (Max 30 pts)
        has_bio = bool(profile.get('bio'))
        has_location = bool(profile.get('location'))
        
        if has_bio:
            score += 10
            strengths.append("Professional Profile: Bio is set up.")
        else:
            weaknesses.append("Ghost Profile: Missing bio/introduction.")
            suggestions.append("Add a professional bio highlighting your main tech stack.")

        if desc_ratio > 0.8 and len(original_repos) > 0:
            score += 20
            strengths.append("Documentation Aware: Most projects have descriptions.")
        elif desc_ratio < 0.3 and len(original_repos) > 0:
            weaknesses.append("Mystery Code: Projects lack descriptions.")
            suggestions.append("Add descriptions and READMEs to your top 3 repositories.")
        else:
            score += 10

        # C. Impact & Community (Max 20 pts)
        if total_stars > 50:
            score += 20
            strengths.append("Community Impact: Your code is being used/admired by others.")
        elif total_stars > 5:
            score += 10
        else:
            suggestions.append("Share your projects on social media (LinkedIn/Twitter) to gain visibility.")

        # D. Consistency (Max 20 pts)
        if active_repos > 3:
            score += 20
            strengths.append("Active Coder: Recent activity detected in multiple repos.")
        elif active_repos == 0 and len(original_repos) > 0:
            weaknesses.append("Stale Profile: No recent activity in original repos.")
            suggestions.append("Commit to a '100 Days of Code' challenge to refresh your timeline.")
        else:
            score += 10

        # Cap Score
        final_score = min(max(score, 0), 100)

        # --- 3. FINAL REPORT GENERATION ---
        
        return {
            "score": final_score,
            "grade": self._get_grade(final_score),
            "summary": self._get_summary(final_score),
            "strengths": strengths,
            "weaknesses": weaknesses,
            "suggestions": suggestions,
            "details": {
                "total_repos": total_repos,
                "original_repos": len(original_repos),
                "fork_ratio": round(fork_ratio * 100, 1),
                "stars": total_stars,
                "active_repos": active_repos
            }
        }

    def _get_grade(self, score: int) -> str:
        if score >= 90: return "A+"
        if score >= 80: return "A"
        if score >= 70: return "B"
        if score >= 50: return "C"
        return "D"

    def _get_summary(self, score: int) -> str:
        if score >= 80:
            return "Recruiter Ready. Your profile shows engineering maturity and impact."
        if score >= 60:
            return "Solid Foundation. Good projects, but needs better presentation/consistency."
        return "Needs Work. Focus on originality and documentation to pass screening."