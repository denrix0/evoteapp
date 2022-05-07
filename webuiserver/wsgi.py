"""Web Server Gateway Interface"""

##################
# FOR PRODUCTION
####################
from src.app import app
import src.config as config

if __name__ == "__main__":
    ####################
    # FOR DEVELOPMENT
    ####################
    context = (
        str((config.basedir.parent / "ssl_stuff" / "server.crt").resolve()),
        str((config.basedir.parent / "ssl_stuff" / "server.key").resolve()),
    )
    app.run(
        debug=True,
        host=config.WEBUI_SERVER_URI,
        port=config.WEBUI_SERVER_PORT,
        ssl_context=context,
    )
