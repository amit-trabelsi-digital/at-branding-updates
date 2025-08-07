#!/usr/bin/env python3
"""
Mental Coach External API - Python Example
דוגמת קוד Python לשימוש ב-API החיצוני של Mental Coach
"""

import requests
import json
from typing import Optional, Dict, List, Any
from datetime import datetime


class MentalCoachAPI:
    """Mental Coach External API Client"""
    
    def __init__(self, api_key: str, base_url: str = "https://api.mentalcoach.app/api/external"):
        """
        Initialize the API client
        
        Args:
            api_key: Your API key
            base_url: API base URL (default: production)
        """
        self.api_key = api_key
        self.base_url = base_url
        self.headers = {
            "X-API-Key": api_key,
            "Content-Type": "application/json"
        }
        self.session = requests.Session()
        self.session.headers.update(self.headers)
    
    def _handle_response(self, response: requests.Response) -> Dict[str, Any]:
        """
        Handle API response and errors
        
        Args:
            response: The HTTP response object
            
        Returns:
            Parsed JSON response
            
        Raises:
            Exception: On API errors
        """
        try:
            response.raise_for_status()
            return response.json()
        except requests.exceptions.HTTPError as e:
            if response.status_code == 429:
                reset_time = response.headers.get('X-RateLimit-Reset')
                print(f"Rate limit exceeded. Reset at: {reset_time}")
            error_msg = response.json().get('message', str(e))
            raise Exception(f"API Error: {error_msg}")
        except requests.exceptions.RequestException as e:
            raise Exception(f"Request failed: {str(e)}")
    
    def create_user(self, user_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Create a new user
        יצירת משתמש חדש
        
        Args:
            user_data: User information dictionary
            
        Returns:
            Created user data
        """
        response = self.session.post(
            f"{self.base_url}/users",
            json=user_data
        )
        return self._handle_response(response)
    
    def bulk_create_users(self, users: List[Dict[str, Any]]) -> Dict[str, Any]:
        """
        Create multiple users in bulk
        יצירת משתמשים בכמות
        
        Args:
            users: List of user dictionaries
            
        Returns:
            Bulk creation results
        """
        response = self.session.post(
            f"{self.base_url}/users/bulk",
            json={"users": users}
        )
        return self._handle_response(response)
    
    def check_user_exists(self, email: Optional[str] = None, 
                         external_id: Optional[str] = None) -> Dict[str, Any]:
        """
        Check if a user exists
        בדיקה האם משתמש קיים
        
        Args:
            email: User's email address
            external_id: External system ID
            
        Returns:
            Existence check result
        """
        params = {}
        if email:
            params['email'] = email
        if external_id:
            params['externalId'] = external_id
            
        response = self.session.get(
            f"{self.base_url}/users/exists",
            params=params
        )
        return self._handle_response(response)
    
    def health_check(self) -> Dict[str, Any]:
        """
        Check API health status
        בדיקת תקינות ה-API
        
        Returns:
            Health status information
        """
        response = self.session.get(f"{self.base_url}/health")
        return self._handle_response(response)


def main():
    """Example usage / דוגמת שימוש"""
    
    # Initialize API client
    api = MentalCoachAPI("mc_dev_your_api_key_here")
    
    try:
        # 1. Check API health
        print("Checking API health...")
        health = api.health_check()
        print(f"API Status: {health['message']}")
        
        # 2. Check if user exists
        print("\nChecking if user exists...")
        exists_check = api.check_user_exists(email="john@example.com")
        print(f"User exists: {exists_check['data']['exists']}")
        
        # 3. Create a new user
        if not exists_check['data']['exists']:
            print("\nCreating new user...")
            new_user = api.create_user({
                "firstName": "John",
                "lastName": "Doe",
                "email": "john@example.com",
                "phone": "0501234567",
                "age": 25,
                "position": "RB",
                "strongLeg": "right",
                "subscriptionType": "premium",
                "externalId": f"USER_{int(datetime.now().timestamp())}",
                "externalSource": "Python_Example"
            })
            print(f"User created: {new_user['data']['user']}")
        
        # 4. Bulk create users
        print("\nCreating multiple users...")
        bulk_result = api.bulk_create_users([
            {
                "firstName": "Alice",
                "lastName": "Smith",
                "email": "alice@example.com",
                "externalId": f"USER_ALICE_{int(datetime.now().timestamp())}"
            },
            {
                "firstName": "Bob",
                "lastName": "Johnson",
                "email": "bob@example.com",
                "externalId": f"USER_BOB_{int(datetime.now().timestamp())}"
            }
        ])
        print(f"Succeeded: {bulk_result['data']['succeeded']}")
        print(f"Failed: {bulk_result['data']['failed']}")
        
    except Exception as e:
        print(f"Error: {e}")


# Async version using aiohttp (optional)
import asyncio
import aiohttp


class AsyncMentalCoachAPI:
    """Async version of Mental Coach API Client"""
    
    def __init__(self, api_key: str, base_url: str = "https://api.mentalcoach.app/api/external"):
        self.api_key = api_key
        self.base_url = base_url
        self.headers = {
            "X-API-Key": api_key,
            "Content-Type": "application/json"
        }
    
    async def create_user(self, user_data: Dict[str, Any]) -> Dict[str, Any]:
        """Create user asynchronously"""
        async with aiohttp.ClientSession() as session:
            async with session.post(
                f"{self.base_url}/users",
                json=user_data,
                headers=self.headers
            ) as response:
                return await response.json()
    
    async def create_users_concurrently(self, users: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Create multiple users concurrently"""
        tasks = [self.create_user(user) for user in users]
        return await asyncio.gather(*tasks)


async def async_example():
    """Async example usage"""
    api = AsyncMentalCoachAPI("mc_dev_your_api_key_here")
    
    users = [
        {
            "firstName": "User1",
            "lastName": "Test",
            "email": f"user1_{int(datetime.now().timestamp())}@example.com",
            "externalId": f"ASYNC_USER1_{int(datetime.now().timestamp())}"
        },
        {
            "firstName": "User2",
            "lastName": "Test",
            "email": f"user2_{int(datetime.now().timestamp())}@example.com",
            "externalId": f"ASYNC_USER2_{int(datetime.now().timestamp())}"
        }
    ]
    
    print("Creating users concurrently...")
    results = await api.create_users_concurrently(users)
    print(f"Created {len(results)} users")


if __name__ == "__main__":
    # Run synchronous example
    main()
    
    # Uncomment to run async example
    # asyncio.run(async_example())