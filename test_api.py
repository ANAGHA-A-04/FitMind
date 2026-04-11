import requests

# Test the food analysis API
url = "http://10.184.213.220:5002/api/food/analyze"
image_path = "pizza.jpg"

with open(image_path, 'rb') as f:
    files = {'image': f}
    response = requests.post(url, files=files)

print(f"Status Code: {response.status_code}")
print(f"Response: {response.json()}")