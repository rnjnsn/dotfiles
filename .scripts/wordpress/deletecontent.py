import csv
import requests
import time

# WordPress configuration
WP_URL = "https://intellectualberlin.com/wp-json/wp/v2"
USERNAME = "info@intellectualberlin.com"
APP_PASSWORD = "lZDB ZgJf Wzwe 3a3L SAlY SR3B"

def clear_page_content():
    """Clear content from all WordPress pages."""
    
    # Authentication
    auth = (USERNAME, APP_PASSWORD)
    
    # Headers
    headers = {
        "Content-Type": "application/json",
    }
    
    # Get all pages with pagination, including all statuses
    all_pages = []
    page = 1
    
    print("Fetching all pages...")
    
    while True:
        try:
            # Get pages, 100 at a time, all statuses
            response = requests.get(
                f"{WP_URL}/pages?per_page=100&page={page}&status=publish,draft,pending,private,future,trash",
                auth=auth
            )
            
            # Check if we've reached the end of pages
            if response.status_code == 400:
                break
                
            if response.status_code != 200:
                print(f"Error fetching page {page}: {response.text}")
                break
                
            pages = response.json()
            
            # If no pages returned, we're done
            if not pages:
                break
            
            # Add these pages to our list
            all_pages.extend(pages)
            print(f"Found {len(pages)} pages on page {page}")
            
            # Move to next page
            page += 1
            
        except Exception as e:
            print(f"Error fetching pages: {str(e)}")
            break
    
    total = len(all_pages)
    cleared = 0
    failed = 0
    
    print(f"\nFound {total} pages in total.")
    print("Starting to clear content...")
    
    # Empty template
    empty_content = """<!-- wp:paragraph -->
<p>Content cleared</p>
<!-- /wp:paragraph -->"""
    
    for page in all_pages:
        try:
            # Get page ID and title
            page_id = page['id']
            page_title = page['title']['rendered']
            
            # Preserve the original status
            original_status = page['status']
            
            # Prepare the update data
            data = {
                "content": empty_content,
                "status": original_status  # Keep original status
            }
            
            # Make the API request to update the page
            update_response = requests.post(
                f"{WP_URL}/pages/{page_id}",
                headers=headers,
                auth=auth,
                json=data
            )
            
            if update_response.status_code == 200:
                print(f"✓ Cleared content from: {page_title} (ID: {page_id})")
                cleared += 1
            else:
                print(f"✗ Failed to clear {page_title}: {update_response.text}")
                failed += 1
                
        except Exception as e:
            try:
                page_title = page['title']['rendered']
            except:
                page_title = f"Page ID {page['id']}"
                
            print(f"✗ Error clearing {page_title}: {str(e)}")
            failed += 1
            
        # Add a small delay to avoid overwhelming the server
        time.sleep(1)
    
    print("\nProcess completed!")
    print(f"Successfully cleared: {cleared} pages")
    print(f"Failed: {failed} pages")
    print(f"Total processed: {total} pages")

if __name__ == "__main__":
    print("WARNING: This will clear content from ALL pages!")
    print("Make sure you have a backup before proceeding.")
    confirmation = input("Type 'YES' to continue: ")
    
    if confirmation == "YES":
        clear_page_content()
    else:
        print("Operation cancelled.")