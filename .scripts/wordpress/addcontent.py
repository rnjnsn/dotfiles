import csv
import requests
import time

# WordPress configuration
WP_URL = "https://intellectualberlin.com/wp-json/wp/v2"
USERNAME = "info@intellectualberlin.com"
APP_PASSWORD = "FpiE ZFT0 yY7s T2PF jDt4 hyqC"  # Replace with your actual app password


def create_markdown_content_structure():
    """Create standardized Markdown content structure for all pages."""
    return """
*[Space for featured image if available]*

*[Space for podcast content]*

## Quick ones

[Quick facts and information]

## Dive deeper

[In-depth content]

### Sources

[List of sources]
"""

def get_all_pages():
    """Get all pages from WordPress using pagination."""
    auth = (USERNAME, APP_PASSWORD)
    all_pages = []
    page_num = 1
    
    print("Retrieving all pages...")
    
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
                return []
                
            pages = response.json()
            
            if not pages:
                print("No more pages found")
                break
            
            # Add pages to our list
            count_on_page = len(pages)
            all_pages.extend(pages)
            
            print(f"Found {count_on_page} pages on page {page_num}")
            page_num += 1
            
        except Exception as e:
            print(f"Error fetching pages: {str(e)}")
            import traceback
            traceback.print_exc()
            return []
    
    print(f"Total pages found: {len(all_pages)}")
    return all_pages

def update_pages():
    """Update all pages with the new Markdown content structure."""
    
    auth = (USERNAME, APP_PASSWORD)
    headers = {
        "Content-Type": "application/json",
    }
    
    # Get all pages
    print("Fetching existing pages...")
    all_pages = get_all_pages()
    
    total = len(all_pages)
    updated = 0
    failed = 0
    
    print(f"\nFound {total} pages.")
    
    if total == 0:
        print("No pages found to update. Check your WordPress API connection.")
        return
        
    print("Starting content structure update...")
    
    for page in all_pages:
        try:
            # Get page ID and title
            page_id = page['id']
            page_title = page['title']['rendered']
            
            # Preserve the original status
            original_status = page['status']
            
            # Prepare the update data
            data = {
                "content": create_markdown_content_structure(),
                "status": "draft"  # Set all to draft for review
            }
            
            print(f"Updating page: {page_title} (ID: {page_id})...")
            
            # Make the API request to update the page
            update_response = requests.post(
                f"{WP_URL}/pages/{page_id}",
                headers=headers,
                auth=auth,
                json=data
            )
            
            if update_response.status_code == 200:
                print(f"✓ Updated structure for: {page_title}")
                updated += 1
            else:
                print(f"✗ Failed to update {page_title}: {update_response.text}")
                failed += 1
                
        except Exception as e:
            try:
                page_title = page['title']['rendered']
            except:
                page_title = f"Page ID {page['id']}"
                
            print(f"✗ Error updating {page_title}: {str(e)}")
            failed += 1
            
        # Add a small delay to avoid overwhelming the server
        time.sleep(1)
    
    print("\nProcess completed!")
    print(f"Successfully updated: {updated} pages")
    print(f"Failed: {failed} pages")
    print(f"Total processed: {total} pages")

if __name__ == "__main__":
    print("Starting to update WordPress pages with new Markdown content structure...")
    print("This will add Markdown placeholders for images, podcast, and sections.")
    print("All pages will be set to draft status.")
    confirmation = input("Type 'YES' to continue: ")
    
    if confirmation == "YES":
        update_pages()
    else:
        print("Operation cancelled.")