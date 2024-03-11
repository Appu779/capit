import openai
from fpdf import FPDF

# Set your OpenAI API key
api_key = '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'
openai.api_key = api_key

def summarize_text(text):
    try:
        # Call OpenAI's summarization API to generate a summary
        response = openai.Completion.create( 
            model="gpt-3.5-turbo-instruct",
            prompt="Summarize the content of the college class lecture while maintaining accuracy, conciseness, and excluding non-relevant details such as teacher chitchats. Ensure that important "+"figures and references are included where necessary. The summary should capture key points, concepts, and discussions comprehensively."+
                    "Please generate a concise summary of the lecture's main topics, covering essential details and omitting superfluous information. Ensure coherence, clarity, and accuracy in the generated notes.:\n\n" + text + "\n\nNotes:"
        )
        summary = response['choices'][0]['text']
        return summary
    except Exception as e:
        print("Error:", e)
        return None

def save_to_pdf(summary, output_file):
    # Create a PDF object
    pdf = FPDF()
    pdf.add_page()
    pdf.set_font("Arial", size=12)
    
    # Add the summary text to the PDF
    pdf.multi_cell(0, 10, txt=summary)
    
    # Save the PDF to the specified output file
    pdf.output(output_file)

def main():
    file_path = 'text.txt'  # Path to the input file
    output_file = 'output.pdf'  # Path to the output PDF file
    
    try:
        # Read the content of the input file
        with open(file_path, 'r') as file:
            text = file.read()
        
        # Summarize the text
        summary = summarize_text(text)
        
        if summary:
            # Save the summary to a PDF file
            print(summary)
            save_to_pdf(summary, output_file)
            print(f"Summary saved to {output_file}")
    
    except FileNotFoundError:
        print("File not found.")

if __name__ == "__main__":
    main()
