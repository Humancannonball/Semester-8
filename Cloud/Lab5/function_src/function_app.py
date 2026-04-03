import datetime
import json
import logging

import azure.functions as func

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)


@app.route(route="hello")
def hello(req: func.HttpRequest) -> func.HttpResponse:
    name = req.params.get("name", "student")
    extra_params = {
        key: value
        for key, value in req.params.items()
        if key != "name"
    }

    payload = {
        "message": f"Hello, {name}! Your Azure Function is running.",
        "timestamp_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "extra_params": extra_params,
    }

    return func.HttpResponse(
        json.dumps(payload, indent=2),
        mimetype="application/json",
        status_code=200,
    )


@app.schedule(
    schedule="0 */1 * * * *",
    arg_name="timer",
    run_on_startup=False,
    use_monitor=True,
)
def heartbeat(timer: func.TimerRequest) -> None:
    now = datetime.datetime.now(datetime.timezone.utc).isoformat()
    if timer.past_due:
        logging.warning("Timer trigger is running later than scheduled.")

    logging.info("Timer trigger executed at %s", now)
