import winrm

def install_sql(host, user, password):
    session = winrm.Session(host, auth=(user, password))

    command = r'''
    Start-Process "C:\SQL\Setup.exe" `
      -ArgumentList "/ConfigurationFile=C:\SQL\configFile.ini /Q" `
      -Wait -NoNewWindow
    '''

    result = session.run_ps(command)

    if result.status_code != 0:
        raise Exception(result.std_err.decode())

    return "COMPLETED"
