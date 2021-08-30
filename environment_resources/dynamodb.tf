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
}


resource "aws_dynamodb_table" "mapping" {
  name = "id-mapping-${terraform.workspace}"
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
