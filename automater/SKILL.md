# Automation Workflow Expert

Expert in building, managing, and optimizing automation workflows. Specializes in web scraping, task scheduling, RAG (Retrieval-Augmented Generation), n8n workflows, LLM-powered automation, and identifying repetitive processes that should be automated for efficiency.

## When to use this skill

- Building web scrapers
- Setting up scheduled tasks and workflows
- Creating RAG (Retrieval-Augmented Generation) systems
- Designing n8n automation workflows
- Integrating LLMs into automation pipelines
- Identifying repetitive manual processes
- Monitoring and alerting systems
- Data pipeline automation
- API integration and orchestration
- Batch processing workflows

## Core Expertise

### Automation Philosophy

**Golden Rule**: If you're doing something more than 3 times, automate it.

#### Signs You Need Automation
- Performing the same task daily/weekly
- Manual data entry or transformation
- Repetitive copy-paste operations
- Regular checking of websites/APIs for changes
- Scheduled report generation
- Multi-step processes that don't require human judgment
- Data synchronization between systems

### Web Scraping

#### Beautiful Soup (Static Sites)
```python
from bs4 import BeautifulSoup
import requests

# Fetch and parse
response = requests.get('https://example.com')
soup = BeautifulSoup(response.content, 'html.parser')

# Extract data
title = soup.find('h1').text
links = [a['href'] for a in soup.find_all('a')]
articles = soup.select('.article-class')

# Handle pagination
for page in range(1, 11):
    url = f'https://example.com?page={page}'
    # ... scrape logic
```

#### Playwright (Dynamic Sites)
```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()

    # Navigate and wait for dynamic content
    page.goto('https://example.com')
    page.wait_for_selector('.content-loaded')

    # Interact with page
    page.click('button#load-more')
    page.fill('input#search', 'query')

    # Extract data
    content = page.inner_text('.main-content')

    browser.close()
```

#### Scrapy (Production Scraping)
```python
import scrapy

class ExampleSpider(scrapy.Spider):
    name = 'example'
    start_urls = ['https://example.com']

    def parse(self, response):
        for article in response.css('.article'):
            yield {
                'title': article.css('h2::text').get(),
                'url': article.css('a::attr(href)').get(),
                'date': article.css('.date::text').get(),
            }

        # Follow pagination
        next_page = response.css('a.next::attr(href)').get()
        if next_page:
            yield response.follow(next_page, self.parse)
```

#### Best Practices for Scraping
- Respect robots.txt
- Add delays between requests (rate limiting)
- Use rotating user agents
- Handle errors gracefully
- Cache responses when developing
- Store raw HTML before parsing (for re-processing)
- Monitor for website structure changes

### Task Scheduling

#### Cron (Linux/Mac)
```bash
# Edit crontab
crontab -e

# Examples:
# Every day at 2 AM
0 2 * * * /path/to/script.sh

# Every Monday at 9 AM
0 9 * * 1 /path/to/script.sh

# Every 15 minutes
*/15 * * * * python /path/to/monitor.py

# Every hour
0 * * * * /path/to/hourly-task.sh

# View scheduled jobs
crontab -l
```

#### Python APScheduler
```python
from apscheduler.schedulers.blocking import BlockingScheduler
from datetime import datetime

scheduler = BlockingScheduler()

# Interval-based scheduling
@scheduler.scheduled_job('interval', minutes=30)
def check_updates():
    print(f'Checking for updates: {datetime.now()}')
    # Your automation logic

# Cron-style scheduling
@scheduler.scheduled_job('cron', hour=9, minute=0)
def morning_report():
    print('Generating morning report')
    # Your automation logic

# One-time scheduled job
scheduler.add_job(
    func=backup_database,
    trigger='date',
    run_date='2025-12-01 00:00:00'
)

scheduler.start()
```

#### Celery (Distributed Task Queue)
```python
from celery import Celery

app = Celery('tasks', broker='redis://localhost:6379/0')

@app.task
def process_data(data_id):
    # Long-running task
    data = fetch_data(data_id)
    result = process(data)
    return result

# Schedule periodic tasks
from celery.schedules import crontab

app.conf.beat_schedule = {
    'daily-cleanup': {
        'task': 'tasks.cleanup',
        'schedule': crontab(hour=2, minute=0),
    },
    'every-15-minutes': {
        'task': 'tasks.monitor',
        'schedule': 900.0,  # 15 minutes in seconds
    },
}
```

### n8n Workflow Automation

#### n8n Setup
```bash
# Using Docker
docker run -it --rm \
  --name n8n \
  -p 5678:5678 \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n

# Or using npm
npm install -g n8n
n8n start
```

#### Common n8n Workflows

**1. Data Sync Between Systems**
- Webhook trigger → Transform data → Send to API → Update database

**2. Monitoring & Alerts**
- Schedule trigger → Check API/website → Condition → Send notification (Slack/Email)

**3. Content Automation**
- RSS feed → Filter → Transform → Post to social media

**4. Data Processing Pipeline**
- File watcher → Parse data → LLM processing → Store results

#### n8n Best Practices
- Use error workflows for handling failures
- Implement retry logic for external API calls
- Log important data at each step
- Use credentials securely (environment variables)
- Version control workflows (export JSON)
- Test with small datasets first

### RAG (Retrieval-Augmented Generation)

#### Simple RAG Implementation
```python
from langchain.vectorstores import Chroma
from langchain.embeddings import OpenAIEmbeddings
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.llms import OpenAI
from langchain.chains import RetrievalQA
from langchain.document_loaders import TextLoader

# Load and split documents
loader = TextLoader('documents.txt')
documents = loader.load()

text_splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000,
    chunk_overlap=200
)
texts = text_splitter.split_documents(documents)

# Create embeddings and vector store
embeddings = OpenAIEmbeddings()
vectorstore = Chroma.from_documents(texts, embeddings)

# Create retrieval chain
qa = RetrievalQA.from_chain_type(
    llm=OpenAI(),
    chain_type="stuff",
    retriever=vectorstore.as_retriever()
)

# Query
query = "What is the main topic?"
answer = qa.run(query)
```

#### Production RAG System
```python
# Using more advanced setup
from langchain_community.vectorstores import Pinecone
from langchain.embeddings import HuggingFaceEmbeddings
from langchain.llms import Together

# Better embeddings
embeddings = HuggingFaceEmbeddings(
    model_name="sentence-transformers/all-mpnet-base-v2"
)

# Persistent vector store
vectorstore = Pinecone.from_documents(
    documents=texts,
    embedding=embeddings,
    index_name="my-index"
)

# Advanced retrieval
retriever = vectorstore.as_retriever(
    search_type="mmr",  # Maximal Marginal Relevance
    search_kwargs={"k": 5, "fetch_k": 20}
)

# Better LLM
llm = Together(
    model="meta-llama/Llama-3-70b-chat-hf",
    temperature=0.1,
)

qa_chain = RetrievalQA.from_chain_type(
    llm=llm,
    chain_type="stuff",
    retriever=retriever,
    return_source_documents=True
)
```

### LLM-Powered Automation

#### Automated Data Extraction
```python
from openai import OpenAI

client = OpenAI()

def extract_invoice_data(invoice_text):
    prompt = f"""Extract the following information from the invoice:
    - Invoice number
    - Date
    - Total amount
    - Vendor name

    Invoice text:
    {invoice_text}

    Return as JSON.
    """

    response = client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt}],
        response_format={"type": "json_object"}
    )

    return response.choices[0].message.content
```

#### Automated Classification
```python
def classify_support_ticket(ticket_text):
    prompt = f"""Classify this support ticket into one of these categories:
    - Technical Issue
    - Billing Question
    - Feature Request
    - Bug Report
    - General Inquiry

    Ticket: {ticket_text}

    Return only the category name.
    """

    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{"role": "user", "content": prompt}]
    )

    return response.choices[0].message.content.strip()
```

#### Automated Content Generation
```python
def generate_social_media_posts(article_url):
    # Scrape article
    article = scrape_article(article_url)

    prompt = f"""Create 3 social media posts for this article:

    Title: {article['title']}
    Summary: {article['summary']}

    Requirements:
    - Engaging and concise
    - Include relevant hashtags
    - Different angles for each post
    """

    response = client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt}]
    )

    return response.choices[0].message.content
```

### Monitoring & Alerting

#### Website Change Monitor
```python
import requests
import hashlib
import time

def monitor_website(url, check_interval=300):
    """Monitor website for changes every 5 minutes"""
    last_hash = None

    while True:
        try:
            response = requests.get(url)
            current_hash = hashlib.md5(response.content).hexdigest()

            if last_hash and current_hash != last_hash:
                send_alert(f"Website changed: {url}")

            last_hash = current_hash
            time.sleep(check_interval)

        except Exception as e:
            send_alert(f"Error monitoring {url}: {e}")
            time.sleep(check_interval)
```

#### API Health Monitor
```python
def monitor_api_health(api_url, threshold_ms=1000):
    """Monitor API response time and status"""
    import time

    start = time.time()
    try:
        response = requests.get(api_url)
        duration_ms = (time.time() - start) * 1000

        if response.status_code != 200:
            send_alert(f"API returned {response.status_code}")

        if duration_ms > threshold_ms:
            send_alert(f"API slow: {duration_ms:.0f}ms")

        return {
            'status': response.status_code,
            'duration_ms': duration_ms,
            'healthy': response.status_code == 200 and duration_ms < threshold_ms
        }

    except Exception as e:
        send_alert(f"API failed: {e}")
        return {'status': 'error', 'error': str(e)}
```

### Data Pipeline Automation

#### ETL Pipeline Example
```python
import pandas as pd
from datetime import datetime

def extract_data():
    """Extract from multiple sources"""
    db_data = pd.read_sql("SELECT * FROM users", connection)
    api_data = pd.DataFrame(requests.get(API_URL).json())
    csv_data = pd.read_csv('daily_data.csv')

    return pd.concat([db_data, api_data, csv_data])

def transform_data(df):
    """Transform and clean data"""
    # Clean
    df = df.drop_duplicates()
    df = df.fillna({'status': 'unknown'})

    # Transform
    df['created_date'] = pd.to_datetime(df['created_date'])
    df['age_days'] = (datetime.now() - df['created_date']).dt.days

    # Filter
    df = df[df['age_days'] < 365]

    return df

def load_data(df):
    """Load to destination"""
    df.to_sql('processed_users', connection, if_exists='replace')
    df.to_parquet(f'backup_{datetime.now():%Y%m%d}.parquet')

# Run pipeline
def run_pipeline():
    try:
        data = extract_data()
        processed = transform_data(data)
        load_data(processed)
        print(f"Pipeline completed: {len(processed)} rows processed")
    except Exception as e:
        send_alert(f"Pipeline failed: {e}")
        raise
```

### Safe Automation Practices

#### Input Validation
```python
def validate_input(data):
    """Always validate inputs"""
    if not isinstance(data, dict):
        raise ValueError("Data must be a dictionary")

    required_fields = ['id', 'email', 'amount']
    for field in required_fields:
        if field not in data:
            raise ValueError(f"Missing required field: {field}")

    if data['amount'] < 0:
        raise ValueError("Amount cannot be negative")

    return True
```

#### Rate Limiting
```python
from time import sleep
from functools import wraps
import time

def rate_limit(calls_per_second=1):
    """Decorator to rate limit function calls"""
    min_interval = 1.0 / calls_per_second
    last_called = [0.0]

    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            elapsed = time.time() - last_called[0]
            wait_time = min_interval - elapsed

            if wait_time > 0:
                sleep(wait_time)

            result = func(*args, **kwargs)
            last_called[0] = time.time()
            return result

        return wrapper
    return decorator

@rate_limit(calls_per_second=2)
def api_call(endpoint):
    return requests.get(endpoint)
```

#### Error Handling and Retries
```python
from tenacity import retry, stop_after_attempt, wait_exponential

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=4, max=10)
)
def robust_api_call(url):
    """Retry with exponential backoff"""
    response = requests.get(url)
    response.raise_for_status()
    return response.json()
```

#### Logging
```python
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('automation.log'),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)

def automated_task():
    logger.info("Starting automated task")
    try:
        result = perform_task()
        logger.info(f"Task completed successfully: {result}")
        return result
    except Exception as e:
        logger.error(f"Task failed: {e}", exc_info=True)
        raise
```

## Automation Patterns

### Pattern 1: Data Sync
```
Schedule → Fetch from Source → Transform → Validate → Load to Destination → Log
```

### Pattern 2: Monitor & Alert
```
Schedule → Check Condition → If Changed/Failed → Send Alert → Log
```

### Pattern 3: Content Pipeline
```
Trigger → Fetch Content → LLM Processing → Validate Output → Publish → Archive
```

### Pattern 4: Batch Processing
```
Schedule → List Files → For Each File → Process → Store Result → Cleanup
```

## Resources

The `resources/` directory contains:
- Common automation templates
- n8n workflow examples
- RAG system configurations
- Scraping patterns library
- Rate limiting configurations

## Scripts

The `scripts/` directory contains:
- `detect-repetition.sh` - Analyze command history for repetitive tasks
- `setup-scheduler.sh` - Setup cron or systemd timers
- `test-automation.sh` - Test automation workflows safely
- `monitor-automation.sh` - Monitor running automations

## Hooks

The `hooks/` directory contains:
- Automation health check hooks
- Failure notification hooks
- Performance monitoring hooks

## Agents

The `agents/` directory contains:
- `repetition-detector` - Identifies repetitive manual tasks
- `workflow-optimizer` - Suggests improvements to automations
- `alert-manager` - Manages alerting logic
- `pipeline-builder` - Builds data pipelines

## Repetition Detection

This skill actively monitors for patterns like:
- Same command run multiple times
- Similar manual data transformations
- Regular checks of websites/APIs
- Repeated file operations
- Manual report generation

When detected, suggests automation approaches.

## Integration with Other Skills

- Works with `/python-dev/` for automation scripting
- Integrates with `/system-manager/` for documentation
- Complements `/data-reporter/` for tracking automation runs
- Supports `/mcp-builder/` for building automation MCPs

## Quick Start Examples

### Simple Daily Report
```python
# Send daily summary email
def daily_report():
    data = fetch_metrics()
    summary = generate_summary(data)
    send_email(to='team@company.com', subject='Daily Report', body=summary)

# Schedule with cron: 0 9 * * * python daily_report.py
```

### Website Monitor
```bash
#!/bin/bash
# Check if website is up
if ! curl -f https://mysite.com > /dev/null 2>&1; then
    echo "Site down!" | mail -s "Alert: Site Down" admin@company.com
fi

# Schedule: */5 * * * * /path/to/monitor.sh
```

## Notes

- Start simple - don't over-engineer
- Test automations thoroughly before production
- Always have error handling and notifications
- Log everything for debugging
- Monitor automation health
- Document what each automation does
- Have rollback plans
- Use version control for automation code
- Regularly review and optimize automations
- Clean up automations that are no longer needed
