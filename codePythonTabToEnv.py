import os
import psycopg2
import datetime
import configparser
import argparse

def execute_sql_files(directory, repo_git, db_params, tab_param_file):
    # Connexion à la BDD
    connection = psycopg2.connect(
        host=db_params["host"],
        dbname=db_params["dbname"], 
        user=db_params["user"], 
        password=db_params["password"]
    )

    cursor = connection.cursor()
    
    # Récupère l'ordre depuis le fichier de paramètres
    with open(os.path.join(tab_param_file), "r") as file:
        order = file.readlines()
    order = [x.strip() for x in order]
    
    log_success = os.path.join(directory, repo_git, "log/success.log")
    log_error = os.path.join(directory, repo_git, "log/error.log")
    
    with open(log_success, "a") as success_file, open(log_error, "a") as error_file:
        # Parcourt tous les fichiers dans l'ordre spécifié
        for foldername in order:
            for root, dirs, files in os.walk(os.path.join(directory, repo_git)):
                if foldername in dirs:
                    folderpath = os.path.join(root, foldername)
                    for subroot, subdirs, subfiles in os.walk(folderpath):
                         for file in subfiles:
                            if file.endswith(".sql"):
                                filepath = os.path.join(subroot, file)
                                with open(filepath, "r") as f:
                                    sql = f.read()
                                    try:
                                        cursor.execute(sql)
                                        success_file.write(f"{datetime.datetime.now()} {file} => exécution OK\n")
                                    except psycopg2.Error as e:
                                        error_file.write(f"{datetime.datetime.now()} {file} => échec d'exécution: {e}\n")
                                        connection.rollback()
        # Enregistre les modifications dans la BDD
        connection.commit()

    # Fermeture curseur et connexion
    cursor.close()
    connection.close()

# Lecture des paramètres à partir du fichier de configuration
config = configparser.ConfigParser()
config.read("fichierDeConfig.1.0.ini")

# Récupère l'environnement à partir de la ligne de commande
parser = argparse.ArgumentParser()
parser.add_argument("environnement", choices=["DEVELOPMENT", "PRODUCTION"])
args = parser.parse_args()
environnement = args.environnement

# Récupère les paramètres de la base de données en fonction de l'environnement spécifié
db_params = {
    "host": config.get(environnement, "db_host"),
    "dbname": config.get(environnement, "db_name"),
    "user": config.get(environnement, "db_user"),
    "password": config.get(environnement, "db_password")
}

# Récupère l'URL du repo Git et le chemin d'accès au fichier de paramètres
repo_git_url = config.get("DEFAULT", "repo_git_url")
tab_param_file = config.get("DEFAULT", "tab_param_file")

# Clone le repo Git s'il n'existe pas déjà
if not os.path.exists(repo_git_url.split("/")[-1]):
    os.system(f"git clone {repo_git_url}")

# Récupère le nom du dossier racine du repo Git
repo_git = repo_git_url.split("/")[-1].split(".")[0]

execute_sql_files(".", repo_git, db_params, tab_param_file)
