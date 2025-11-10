from flask import Flask, request, send_file, jsonify
import subprocess, tempfile, os, werkzeug
from pathlib import Path

app = Flask(__name__)

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "ok"}), 200

@app.route('/convert', methods=['POST'])
def convert_docx_to_pdf():
    if 'file' not in request.files:
        return {"error": "No file uploaded under field 'file'"}, 400

    file: werkzeug.datastructures.FileStorage = request.files['file']
    filename = file.filename or "input.docx"
    if not filename.lower().endswith('.docx'):
        return {"error": "Uploaded file must be a .docx"}, 400

    with tempfile.TemporaryDirectory() as tmpdir:
        input_path = os.path.join(tmpdir, "input.docx")
        output_path = os.path.join(tmpdir, "input.pdf")
        file.save(input_path)
        cmd = [
            "libreoffice", "--headless", "--convert-to", "pdf",
            "--outdir", tmpdir, input_path
        ]
        try:
            proc = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True, timeout=120)
        except subprocess.CalledProcessError as e:
            return {"error": "Conversion failed", "stderr": e.stderr.decode()}, 500
        except subprocess.TimeoutExpired:
            return {"error": "Conversion timeout"}, 500

        if not os.path.exists(output_path):
            return {"error": "Conversion did not produce PDF"}, 500

        return send_file(output_path, mimetype="application/pdf", as_attachment=True, download_name=Path(filename).with_suffix('.pdf').name)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)