def verify_sql(host, user, password):
    session = winrm.Session(host, auth=(user, password))
    result = session.run_ps("Get-Service MSSQLSERVER")

    if "Running" in result.std_out.decode():
        return "COMPLETED"
    else:
        return "FAILED"
