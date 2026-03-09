@echo off
cd /d %~dp0

echo Virtual environment ellenorzes...
IF NOT EXIST .venv (
    echo Letrehozom a virtualis kornyezetet...
    python -m venv .venv
)

echo Virtualis kornyezet aktivalasa...
call .venv\Scripts\activate

echo Csomagok telepitese...
.venv\Scripts\python -m pip install -r requirements.txt

echo Szerver inditasa...
.venv\Scripts\python -m uvicorn main:app --reload

pause