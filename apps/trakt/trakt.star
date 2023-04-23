"""
Applet: Trakt
Summary: Track your tv shows and movies
Description: Trakt lets you keep track and discover tv shows and movies.
Author: Daniel Sitnik
"""

load("cache.star", "cache")
load("encoding/base64.star", "base64")
load("encoding/json.star", "json")
load("http.star", "http")
load("math.star", "math")
load("render.star", "render")
load("secret.star", "secret")
load("schema.star", "schema")

TRAKT_CLIENT_ID = "3ca45a4efaef511a2ad2deb45298f0d76ab4a87f6cf2efab65905703fdcf221d"
TRAKT_CLIENT_SECRET = "AV6+xWcEa9HpKE4vKga7ey1YSgS2jCydFTQQzqGEWzLDZq14T9dsnArfBapSt474hcbzJQVIGpiHiJVjrl1qDD1PPPmZtC1Lf75U5ucxzQLe2t4S3L4UIqtX/7lZORkf9WcAT9019t3690XIlvg3AyxC9aUvlQ9KlvbYKIvY5VNSIxFiZ+cC/HgfwZLgVX7AV1ETzkRYp6FPHIVm85t3nW9+BvMfjg=="
TRAKT_API_URL = "https://api.trakt.tv"
TRAKT_AUTH_ENDPOINT = TRAKT_API_URL + "/oauth/authorize"
TRAKT_TOKEN_ENDPOINT = TRAKT_API_URL + "/oauth/token"

TRAKT_LOGO = base64.decode("""
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
""")

# https://appauth.tidbyt.com/{{ your_app_id }}
# TIDBYT_REDIRECT_URI = "https://oauthdebugger.com/debug"
TIDBYT_REDIRECT_URI = "http://127.0.0.1:8080/oauth-callback"

CACHE_TTL = 60 * 60 * 24  # updates once daily

DEFAULT_DISPLAY = "stats"

DEBUG = True

def main(config):
    refresh_token = config.get("auth")
    display_type = config.get("display", DEFAULT_DISPLAY)

    # TODO: check token availability and possible rate limit?
    if refresh_token == None:
        return render.Root(child = render.Text("Need auth"))
    
    if DEBUG:
        print("current refresh token: %s" % refresh_token)
        print("cached access token: %s" % cache.get(refresh_token))

    if display_type == DEFAULT_DISPLAY:
        return render_stats(config, refresh_token)

    message = "Hello, world!"
    return render.Root(
        child = render.Text(message),
    )

def render_stats(config, refresh_token):
    # TODO: if we have no token, render a default view
    # if not refresh_token:

    access_token = cache.get(refresh_token);

    if not access_token:
        access_token = refresh_access_token(refresh_token)
    
    # TODO: try to retrieve stats from cache first

    res = http.get(TRAKT_API_URL + "/users/me/stats", headers = {
        "trakt-api-version": "2",
        "trakt-api-key": TRAKT_CLIENT_ID,
        "authorization": "Bearer " + access_token
    })

    if res.status_code != 200:
        fail("user stats request failed with status code %d: %s" % (res.status_code, res.body()))
    
    stats = res.json()
    movie_minutes = stats["movies"]["minutes"]
    episode_minutes = stats["episodes"]["minutes"]

    return render.Root(
        child = render.Column(
            children = [
                render.Padding(
                    pad = 1,
                    child = render.Image(src = TRAKT_LOGO, height = 12)
                ),
                render.Marquee(
                    width = 64,
                    child = render.Text("Movies: %s" % minutes_to_days(movie_minutes))
                ),
                render.Text("Shows: %d" % episode_minutes),
            ]
        )
    )

def refresh_access_token(refresh_token):
    if DEBUG:
        print("refreshing access token")

    res = http.post(
        url = TRAKT_TOKEN_ENDPOINT,
        headers = {
            "accept": "application/json",
            "content-type": "application/json"
        },
        json_body = {
            "refresh_token": refresh_token,
            "client_id": TRAKT_CLIENT_ID,
            "client_secret": secret.decrypt(TRAKT_CLIENT_SECRET),
            "redirect_uri": TIDBYT_REDIRECT_URI,
            "grant_type": "refresh_token",
        }
    )

    if res.status_code != 200:
        fail("token request failed with status code %d: %s" % (res.status_code, res.body()))
    
    token_params = res.json()
    access_token = token_params["access_token"]
    new_refresh_token = token_params["refresh_token"]
    ttl = int(token_params["expires_in"]) - 30

    cache.set(new_refresh_token, access_token, ttl)

    if DEBUG:
        print("new access token: %s" % access_token)
        print("new refresh token: %s" % refresh_token)

    return access_token

def get_schema():
    display_options = [
        schema.Option(value = "stats", display = "All-time Stats"),
        schema.Option(value = "trend_shows", display = "Trending Shows"),
        schema.Option(value = "trend_movies", display = "Trending Movies"),
    ]

    return schema.Schema(
        version = "1",
        fields = [
            schema.OAuth2(
                id = "auth",
                name = "Trakt",
                desc = "Connect your Trakt account.",
                icon = "user",
                handler = oauth_handler,
                client_id = TRAKT_CLIENT_ID,
                authorization_endpoint = TRAKT_AUTH_ENDPOINT,
                scopes = [""]
            ),
            schema.Dropdown(
                id = "display",
                name = "Display",
                desc = "Which information do you want to display?",
                icon = "display",
                options = display_options,
                default = DEFAULT_DISPLAY
            )
        ],
    )

def oauth_handler(params):
    params = json.decode(params)
	
    # call the token endpoint
    res = http.post(
        url = TRAKT_TOKEN_ENDPOINT,
        headers = {
            "accept": "application/json",
            "content-type": "application/json"
        },
        json_body = {
            "code": params.get("code"),
            "client_id": TRAKT_CLIENT_ID,
            "client_secret": secret.decrypt(TRAKT_CLIENT_SECRET),
            "redirect_uri": TIDBYT_REDIRECT_URI,
            "grant_type": "authorization_code"
        }
    )

    # check error
    if res.status_code != 200:
        fail("token request failed with status code %d: %s" % (res.status_code, res.body()))
    
    # extract params from response
    token_params = res.json()
    refresh_token = token_params["refresh_token"]
    access_token = token_params["access_token"]
    ttl = int(token_params["expires_in"]) - 30

    # grab the user's trakt username
    res = http.get(TRAKT_API_URL + "/users/me", headers = {
        "trakt-api-version": "2",
        "trakt-api-key": TRAKT_CLIENT_ID,
        "Authorization": "Bearer " + access_token
    })

    # check error
    if res.status_code != 200:
        fail("user profile request failed with status code %d: %s" % (res.status_code, res.body()))
    
    # grab user profile data
    user_profile = res.json()
    username = user_profile["ids"]["slug"]

    # cache tokens and username
    cache.set(refresh_token, access_token, ttl)
    cache.set("%s/username" % refresh_token, username, ttl_seconds = CACHE_TTL)

    return refresh_token

def minutes_to_days(minutes):
    days = minutes // 1440
    hours = math.floor(((minutes / 1440) - days) * 24)

    if days > 0:
        return "%dd %dh" % (days, hours)
    else:
        return "%dh" % hours
