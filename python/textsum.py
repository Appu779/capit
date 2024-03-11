from PyPDF2 import PdfReader
from langchain_openai import ChatOpenAI
from langchain.docstore.document import Document
from langchain.prompts import PromptTemplate
from langchain.chains.summarize import load_summarize_chain
import os

# Replace with your own OpenAI API key
open_api_key = "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"
os.environ["OPENAI_API_KEY"] = open_api_key

# Path to the PDF file
pdf_path = 'text.pdf'

# Extract text from PDF
pdfreader = PdfReader(pdf_path)
text = ''
for i, page in enumerate(pdfreader.pages):
    content = page.extract_text()
    if content:
        text += content

# Prepare documents for summarization
docs = [Document(page_content=text)]

# Load LLM and Summarization Chain
llm = ChatOpenAI(temperature=0, model_name='gpt-3.5-turbo')
template = '''create a student friendly notes : {text}'''

prompt = PromptTemplate(
    input_variables=['text'],
    template=template
)

chain = load_summarize_chain(
    llm,
    chain_type='stuff',
    prompt=prompt,
    verbose=False
)

output_summary = chain.invoke(docs)

# Extract summary text from the dictionary
summary_text = output_summary['output_text']

# Write summary text to a text file
with open("summary.txt", "w") as output_file:
    output_file.write(summary_text)


print("Summary written to 'summary.txt'")
