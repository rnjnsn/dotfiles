import csv
import requests
import time

# WordPress configuration
WP_URL = "https://intellectualberlin.com/wp-json/wp/v2"
USERNAME = "info@intellectualberlin.com"
APP_PASSWORD = "FpiE ZFT0 yY7s T2PF jDt4 hyqC"

def create_page_template(name):
    """Generate empty HTML template for a location page."""
    return f"""<!-- wp:heading {{\"level\":1}} -->
<h1>{name}</h1>
<!-- /wp:heading -->

<!-- wp:paragraph {{\"className\":\"introduction\"}} -->
<p>[Introduction about {name} goes here]</p>
<!-- /wp:paragraph -->

<!-- wp:heading -->
<h2>Historical Significance</h2>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>[Historical information about {name} goes here]</p>
<!-- /wp:paragraph -->

<!-- wp:heading -->
<h2>Key Features</h2>
<!-- /wp:heading -->

<!-- wp:list -->
<ul>
<li>[Feature 1]</li>
<li>[Feature 2]</li>
<li>[Feature 3]</li>
</ul>
<!-- /wp:list -->

<!-- wp:heading -->
<h2>Visiting Information</h2>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>[Visiting information for {name} goes here]</p>
<!-- /wp:paragraph -->

<!-- wp:heading -->
<h2>Related Locations</h2>
<!-- /wp:heading -->

<!-- wp:list -->
<ul>
<li>[Related location 1]</li>
<li>[Related location 2]</li>
<li>[Related location 3]</li>
</ul>
<!-- /wp:list -->"""

def create_wordpress_pages():
    """Create draft pages in WordPress via REST API."""
    
    # Authentication
    auth = (USERNAME, APP_PASSWORD)
    
    # Headers
    headers = {
        "Content-Type": "application/json",
    }
    
    # Read locations from CSV
    with open('locations.csv', 'r', encoding='utf-8') as file:
        csv_reader = csv.DictReader(file)
        locations = list(csv_reader)
    
    total = len(locations)
    created = 0
    failed = 0
    
    print(f"Found {total} locations in CSV file.")
    print("Starting page creation...")
    
    for location in locations:
        # Prepare the page data
        data = {
            "title": location["name"],
            "content": create_page_template(location["name"]),
            "status": "draft",
            "slug": location["slug"]
        }
        
        try:
            # Make the API request
            response = requests.post(
                f"{WP_URL}/pages",
                headers=headers,
                auth=auth,
                json=data
            )
            
            if response.status_code == 201:
                print(f"✓ Created draft page: {location['name']}")
                created += 1
            else:
                print(f"✗ Failed to create {location['name']}: {response.text}")
                failed += 1
                
        except Exception as e:
            print(f"✗ Error creating {location['name']}: {str(e)}")
            failed += 1
            
        # Add a small delay to avoid overwhelming the server
        time.sleep(1)
    
    print("\nProcess completed!")
    print(f"Successfully created: {created} pages")
    print(f"Failed: {failed} pages")
    print(f"Total processed: {total} pages")

if __name__ == "__main__":
    print("Starting to create WordPress pages from CSV...")
    print("This will create draft pages for all locations.")
    print("You can edit the content later in WordPress admin.")
    input("Press Enter to continue...")
    
    create_wordpress_pages()