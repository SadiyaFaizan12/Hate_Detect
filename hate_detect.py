# Import necessary libraries
from flask import Flask, request, jsonify
from transformers import AutoModelForSequenceClassification, AutoTokenizer, BertTokenizer, BertForSequenceClassification
import torch
from langdetect import detect
from googletrans import Translator

app = Flask(__name__)

tokenizer2 = AutoTokenizer.from_pretrained('nlptown/bert-base-multilingual-uncased-sentiment')

model2 = AutoModelForSequenceClassification.from_pretrained('nlptown/bert-base-multilingual-uncased-sentiment')


# Load pre-trained BERT model and tokenizer
model_name = 'bert-base-uncased'
tokenizer = BertTokenizer.from_pretrained(model_name)
model = BertForSequenceClassification.from_pretrained(model_name, num_labels=2)  # 2 labels: hate speech or not

def detect_hate_speech(sentence):
    tokens = tokenizer2.encode(sentence, return_tensors='pt')
    result = model2(tokens)
    a=result.logits
    final=int(torch.argmax(a))+1
    
    # Tokenize input sentence
    inputs = tokenizer(sentence, padding=True, truncation=True, return_tensors='pt')

    # Forward pass through the model
    outputs = model(**inputs)

    # Get predicted class (0: not hate speech, 1: hate speech)
    predicted_class = torch.argmax(outputs.logits, dim=1).item()

    return predicted_class+final

def translate_to_english(sentence):
    translator = Translator()
    translated = translator.translate(sentence, dest='en')
    return translated.text

@app.route('/detect_hate_speech', methods=['POST'])
def handle_hate_speech_detection():
    if request.method == 'POST':
        data = request.get_json()
        input_sentence = data['text']

        # Check if the input sentence is in English
        
        input_sentence = translate_to_english(input_sentence)

        # Fine-tune BERT model on hate speech dataset for better accuracy
        prediction = detect_hate_speech(input_sentence)
        if prediction >= 4:
            result = 'Nope'
        else:
            result = 'Hate Speech'

        return jsonify(result)



if __name__ == '__main__':
    app.run(debug=True)
