# -*- coding: utf-8 -*-

from flask import Flask, request, jsonify
import MeCab

tokenizer = MeCab.Tagger('-Ochasen -r ./mecabrc')
tokenizer.parse('')

app = application = Flask(__name__)
app.config["JSON_AS_ASCII"] = False


def extract_keywords(text):
    keywords = []
    node = tokenizer.parseToNode(text)
    while node:
        word = node.surface
        w = node.feature.split(',')
        if w[0] == '名詞' and len(word) > 1:
            if w[1] in ['固有名詞', '一般']:
                keywords.append(word)
        node = node.next
    return keywords


@app.route('/ping', methods=['GET'])
def ping():
    test_text = '明日はスカイツリーに遊びに行きます'
    keywords = extract_keywords(test_text)
    if len(keywords) > 0:
        status_code = 200
        res = {'status_code': status_code}
    else:
        status_code = 500
        res = {'status_code': status_code, 'message': 'Internal server error'}
    return jsonify(res), status_code


@app.route('/keywords', methods=['POST'])
def keywords():
    data = request.get_json()
    text = data.get('text')
    if text:
        keywords = extract_keywords(text)
        body = {'keywords': keywords}
        status_code = 200
    else:
        status_code = 400
        body = {'message': "request_body must be contain the key 'text'", 'status_code': status_code}
    return jsonify(body), status_code

 
if __name__ == '__main__':
    app.run()
