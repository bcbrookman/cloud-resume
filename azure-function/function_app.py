import azure.functions as func
import azurefunctions.extensions.bindings.cosmosdb as cosmos
import json


app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

@app.route(route="visitors", methods=["GET", "POST"])
@app.cosmos_db_input(arg_name="container",
                     connection="CosmosDBConnection",
                     database_name="cloud_resume",
                     container_name="visitor_counter")
def visitors(req: func.HttpRequest, container: cosmos.ContainerProxy):

    def get_counter() -> dict:
        item = container.read_item(
            item='917ded2f-6325-45f9-983f-291016e0d239',  # "id" of the item
            partition_key='v1'                            # partition key VALUE, not path
        )
        return item

    def get_visitor_count() -> int:
        counter = get_counter()
        return { "visitors": counter['count'] }

    def increment_visitor_count() -> int:
        counter = get_counter()
        counter['count'] += 1
        updated_counter = container.upsert_item(counter)
        return { "visitors": updated_counter['count'] }

    if req.method == "GET":
        response = get_visitor_count()
    elif req.method == "POST":
        response = increment_visitor_count()

    return func.HttpResponse(
        json.dumps(response),
        mimetype="application/json",
        charset="utf-8"
    )
