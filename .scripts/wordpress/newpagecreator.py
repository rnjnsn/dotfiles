import csv
import requests
import time

# WordPress configuration
WP_URL = "https://intellectualberlin.com/wp-json/wp/v2"
USERNAME = "info@intellectualberlin.com"
APP_PASSWORD = "FpiE ZFT0 yY7s T2PF jDt4 hyqC"

def get_existing_pages():
    """Get a list of all existing page slugs."""
    auth = (USERNAME, APP_PASSWORD)
    existing_slugs = set()
    page_num = 1
    
    print("Retrieving existing pages...")
    
    while True:
        try:
            print(f"Fetching page {page_num} of results...")
            response = requests.get(
                f"{WP_URL}/pages?per_page=100&page={page_num}&status=publish,draft,pending,private,future",
                auth=auth
            )
            
            if response.status_code == 400:
                print("Reached end of pages")
                break
                
            if response.status_code != 200:
                print(f"Error fetching pages: {response.text}")
                return set()
                
            pages = response.json()
            
            if not pages:
                print("No more pages found")
                break
                
            # Add slugs to our set (converting to lowercase)
            count_on_page = 0
            for page_data in pages:
                slug = page_data['slug'].lower()
                existing_slugs.add(slug)
                count_on_page += 1
                
            print(f"Found {count_on_page} pages on page {page_num}")
            page_num += 1
            
        except Exception as e:
            print(f"Error fetching pages: {str(e)}")
            return set()
    
    print(f"Total existing pages found: {len(existing_slugs)}")
    
    # Print existing slugs for verification (optional)
    if len(existing_slugs) > 0:
        print("\nExisting page slugs:")
        for slug in sorted(existing_slugs):
            print(f"  - {slug}")
    
    return existing_slugs

def check_and_create_empty_pages():
    """Check existing pages and create empty ones for missing locations."""
    auth = (USERNAME, APP_PASSWORD)
    headers = {
        "Content-Type": "application/json",
    }
    
    print("Fetching existing pages...")
    existing_slugs = get_existing_pages()
    print(f"Found {len(existing_slugs)} existing pages.")
    
    try:
        with open('locations.csv', 'r', encoding='utf-8') as file:
            csv_reader = csv.DictReader(file)
            locations = list(csv_reader)
    except FileNotFoundError:
        print("Error: locations.csv file not found!")
        return
    except Exception as e:
        print(f"Error reading CSV file: {str(e)}")
        return
    
    total = len(locations)
    created = 0
    skipped = 0
    failed = 0
    
    print(f"\nFound {total} locations in CSV file.")
    
    # Print CSV slugs for verification
    print("\nCSV location slugs:")
    csv_slugs = [location["slug"].lower() for location in locations]
    for slug in sorted(csv_slugs[:5]):  # Show just the first 5 for brevity
        print(f"  - {slug}")
    if total > 5:
        print(f"  ... and {total - 5} more")
    
    # Check for duplicates in CSV
    duplicate_check = {}
    for location in locations:
        slug = location["slug"].lower()
        if slug in duplicate_check:
            duplicate_check[slug] += 1
        else:
            duplicate_check[slug] = 1
    
    duplicates = {slug: count for slug, count in duplicate_check.items() if count > 1}
    if duplicates:
        print("\nWarning: Duplicates found in CSV file:")
        for slug, count in duplicates.items():
            print(f"  - {slug}: appears {count} times")
    
    print("\nStarting empty page creation check...")
    
    for location in locations:
        # Convert to lowercase for case-insensitive comparison
        location_slug = location["slug"].lower()
        
        if location_slug in existing_slugs:
            print(f"→ Skipping existing page: {location['name']} (slug: {location_slug})")
            skipped += 1
            continue
            
        # Create empty page with just title and slug
        data = {
            "title": location["name"],
            "status": "draft",
            "slug": location_slug,
            "content": ""  # Empty content
        }
        
        try:
            response = requests.post(
                f"{WP_URL}/pages",
                headers=headers,
                auth=auth,
                json=data
            )
            
            if response.status_code == 201:
                print(f"✓ Created empty page: {location['name']} (slug: {location_slug})")
                created += 1
                # Add to existing slugs so we don't create it again if there's a duplicate in CSV
                existing_slugs.add(location_slug)
            else:
                print(f"✗ Failed to create {location['name']}: {response.text}")
                failed += 1
                
        except Exception as e:
            print(f"✗ Error creating {location['name']}: {str(e)}")
            failed += 1
            
        time.sleep(1)
    
    print("\nProcess completed!")
    print(f"Existing pages skipped: {skipped}")
    print(f"New empty pages created: {created}")
    print(f"Failed attempts: {failed}")
    print(f"Total processed: {total}")

if __name__ == "__main__":
    print("Starting to create empty WordPress pages from CSV...")
    print("This will create empty draft pages only for locations that don't exist yet.")
    confirmation = input("Type 'YES' to continue: ")
    
    if confirmation == "YES":
        check_and_create_empty_pages()
    else:
        print("Operation cancelled.")