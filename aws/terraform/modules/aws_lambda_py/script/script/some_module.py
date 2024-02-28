import requests


def fetch_page(url):
    response = requests.get(url)
    return response.text
