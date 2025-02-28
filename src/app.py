from flask import Flask, render_template, request
import psycopg2
import os

DB_HOST = os.getenv("DB_HOST")
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")

app = Flask(__name__)

def connect_db():
    return psycopg2.connect(
        host=DB_HOST,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD
    )

@app.route('/', methods=['GET', 'POST'])
def home():
    if request.method == 'POST':
        name = request.form['name']
        position = request.form['position']
        conn = connect_db()
        cursor = conn.cursor()
        cursor.execute("INSERT INTO employees (name, position) VALUES (%s, %s)", (name, position))
        conn.commit()
        cursor.close()
        conn.close()
    return render_template('index.html', title="Flask & PostgreSQL Example")

@app.route('/employees', methods=['GET'])
def employees():
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("SELECT name, position FROM employees")
    employees = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('employees.html', title="All Employees", employees=employees)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001)
