import json
import boto3
from datetime import datetime
from decimal import Decimal

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("OutageLogs")


class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return int(obj) if obj % 1 == 0 else float(obj)
        return super().default(obj)


def load_outages_from_dynamodb():
    try:
        response = table.scan()
        items = response.get("Items", [])
        for item in items:
            if "LogID" in item:
                del item["LogID"]
        items_sorted = sorted(items, key=lambda x: x.get("id", 0), reverse=True)
        return items_sorted
    except Exception as e:
        print(f"Error loading outages: {e}")
        return []


def save_outage_to_dynamodb(outage_data):
    try:
        existing_outages = load_outages_from_dynamodb()
        next_id = max([item.get("id", 0) for item in existing_outages], default=0) + 1

        outage_record = {
            "LogID": str(next_id),
            "id": next_id,
            "date": outage_data["date"],
            "time": outage_data["time"],
            "stage": outage_data["stage"],
            "logged_at": datetime.now().isoformat()
        }

        table.put_item(Item=outage_record)

        returned_record = outage_record.copy()
        del returned_record["LogID"]
        return returned_record
    except Exception as e:
        print(f"Error saving outage: {e}")
        raise


def validate_outage_data(data):
    if not data:
        return False, "No data provided"
    if "date" not in data:
        return False, "Missing date"
    if "time" not in data:
        return False, "Missing time"
    if "stage" not in data:
        return False, "Missing stage"
    return True, "Valid"


def success_response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body, cls=DecimalEncoder)
    }


def error_response(status_code, message):
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"error": message}, cls=DecimalEncoder)
    }


def handle_log_outage(event):
    try:
        body = json.loads(event["body"])
        is_valid, message = validate_outage_data(body)
        if not is_valid:
            return error_response(400, message)

        outage_record = save_outage_to_dynamodb(body)
        return success_response(201, {
            "message": "Outage logged successfully",
            "outage": outage_record
        })
    except json.JSONDecodeError:
        return error_response(400, "Invalid JSON in request body")
    except Exception as e:
        print(f"Error in handle_log_outage: {e}")
        return error_response(500, f"Server error: {str(e)}")


def handle_get_outages(event):
    try:
        outages = load_outages_from_dynamodb()
        return success_response(200, {
            "total": len(outages),
            "outages": outages
        })
    except Exception as e:
        print(f"Error in handle_get_outages: {e}")
        return error_response(500, f"Server error: {str(e)}")


def lambda_handler(event, context):
    print(f"Full event: {json.dumps(event)}")

    http_method = event.get("httpMethod", "GET")
    resource_path = event.get("resource", "/")

    print(f"Received {http_method} request to resource: {resource_path}")

    if resource_path == "/log-outage" and http_method == "POST":
        return handle_log_outage(event)

    elif resource_path == "/outages" and http_method == "GET":
        return handle_get_outages(event)

    else:
        return error_response(404, f"Endpoint {http_method} {resource_path} not found")
