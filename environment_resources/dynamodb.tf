# ========================================
# To store the product_id mapping
# ========================================
locals {
  table_attributes = {
    "id" : "S"
    "fin" : "S"
    "orderNumber" : "S"
    "externalId" : "S"
    "vin" : "S"
    "updatedAt" : "N"
    "createdAt" : "N"
    "deleted" : "S"
  }

  event_table_attributes = {
    "unique_id" : "S"
    "market" : "S"
    "product_id" : "S"
    "saga_id" : "S"
    "event_name" : "S"
    "timestamp" : "N"
  }

  index_attributes = {
    "fin" : {
      "name" : "fin-index",
      "hash_key" : "fin",
      "range_key" : "",
      "write_capacity" : 15,
      "read_capacity" : 15,
      "projection_type" : "ALL",
      "non_key_attributes" : []
    }
    "orderNumber" : {
      "name" : "orderNumber-index",
      "hash_key" : "orderNumber",
      "range_key" : "",
      "write_capacity" : 15,
      "read_capacity" : 15,
      "projection_type" : "ALL",
      "non_key_attributes" : []
    }
    "externalId" : {
      "name" : "externalId-index",
      "hash_key" : "externalId",
      "range_key" : "",
      "write_capacity" : 15,
      "read_capacity" : 15,
      "projection_type" : "ALL",
      "non_key_attributes" : []
    }
    "vin" : {
      "name" : "vin-index",
      "hash_key" : "vin",
      "range_key" : "",
      "write_capacity" : 15,
      "read_capacity" : 15,
      "projection_type" : "ALL",
      "non_key_attributes" : []
    }
    "updatedAt" : {
      "name" : "updatedAt-index",
      "hash_key" : "updatedAt",
      "range_key" : "",
      "write_capacity" : 15,
      "read_capacity" : 15,
      "projection_type" : "ALL",
      "non_key_attributes" : []
    }
    "createdAt" : {
      "name" : "createdAt-index",
      "hash_key" : "createdAt",
      "range_key" : "",
      "write_capacity" : 15,
      "read_capacity" : 15,
      "projection_type" : "ALL",
      "non_key_attributes" : []
    }
    "deleted" : {
      "name" : "deleted-index",
      "hash_key" : "deleted",
      "range_key" : "",
      "write_capacity" : 15,
      "read_capacity" : 15,
      "projection_type" : "ALL",
      "non_key_attributes" : []
    }
  }
  event_index_attributes = {
    "saga_id" : { "name" : "saga_id", "hash_key" : "saga_id", "range_key" : "timestamp", "projection_type" : "ALL", "non_key_attributes" : [] }
    "product_id" : { "name" : "product_id", "hash_key" : "product_id", "range_key" : "timestamp", "projection_type" : "ALL", "non_key_attributes" : [] }
  }
}


resource "aws_dynamodb_table" "identity" {
  count          = length(local.categories)
  name = "${local.categories[count.index]}-identity-${terraform.workspace}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "id"
  stream_enabled = false

  dynamic "attribute" {
    for_each = local.table_attributes
    content {
      name = attribute.key
      type = attribute.value
    }
  }

  dynamic "global_secondary_index" {
    for_each = local.index_attributes
    content {
      name = global_secondary_index.value["name"]
      hash_key = global_secondary_index.value["hash_key"]
      range_key = global_secondary_index.value["range_key"]
      write_capacity = global_secondary_index.value["write_capacity"]
      read_capacity = global_secondary_index.value["read_capacity"]
      projection_type = global_secondary_index.value["projection_type"]
      non_key_attributes = global_secondary_index.value["non_key_attributes"]
    }
  }

  point_in_time_recovery {
    enabled = contains([
      "int",
      "prod"], terraform.workspace) ? true : false
  }

  timeouts {
    update = "24h"
  }

  tags = {
    Terraform = "true"
    Environment = terraform.workspace
  }
}

# ========================================
# To store the events index
# ========================================
locals {
  tableName = "kahula-events-${terraform.workspace}"
  categories = ["connect","collect","vehicle"]
}

resource "aws_dynamodb_table" "events_table" {
  count          = length(local.categories)
  name           = "${local.categories[count.index]}-events-${terraform.workspace}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "unique_id"
  range_key      = "timestamp"
  stream_enabled = false

  dynamic "attribute" {
    for_each = local.event_table_attributes
    content {
      name = attribute.key
      type = attribute.value
    }
  }

  dynamic "global_secondary_index" {
    for_each = local.event_index_attributes
    content {
      name               = "${global_secondary_index.value["name"]}-index"
      hash_key           = global_secondary_index.value["hash_key"]
      range_key          = global_secondary_index.value["range_key"]
      projection_type    = global_secondary_index.value["projection_type"]
      non_key_attributes = global_secondary_index.value["non_key_attributes"]
    }
  }

  point_in_time_recovery {
    enabled = terraform.workspace == "prod" ? true : false
  }

  timeouts {
    update = "24h"
  }

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
  }
}