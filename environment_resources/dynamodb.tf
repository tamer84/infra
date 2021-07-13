# ========================================
# To store the vpp_id - fin mapping
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
  name           = "vppid-mapping-${terraform.workspace}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
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
      name               = global_secondary_index.value["name"]
      hash_key           = global_secondary_index.value["hash_key"]
      range_key          = global_secondary_index.value["range_key"]
      write_capacity     = global_secondary_index.value["write_capacity"]
      read_capacity      = global_secondary_index.value["read_capacity"]
      projection_type    = global_secondary_index.value["projection_type"]
      non_key_attributes = global_secondary_index.value["non_key_attributes"]
    }
  }

  point_in_time_recovery {
    enabled = contains(["int", "prod"], terraform.workspace) ? true : false
  }

  timeouts {
    update = "24h"
  }

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
  }
}


# ========================================
# Main key autoscaling
# ========================================
# resource "aws_appautoscaling_target" "mainkey_read_target" {
#   max_capacity       = 100
#   min_capacity       = 5
#   resource_id        = "table/${aws_dynamodb_table.mapping.id}"
#   scalable_dimension = "dynamodb:table:ReadCapacityUnits"
#   service_namespace  = "dynamodb"
# }

# resource "aws_appautoscaling_policy" "mainkey_read_policy" {
#   name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.mainkey_read_target.resource_id}"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = aws_appautoscaling_target.mainkey_read_target.resource_id
#   scalable_dimension = aws_appautoscaling_target.mainkey_read_target.scalable_dimension
#   service_namespace  = aws_appautoscaling_target.mainkey_read_target.service_namespace

#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "DynamoDBReadCapacityUtilization"
#     }

#     target_value = 70
#   }
# }

# resource "aws_appautoscaling_target" "mainkey_write_target" {
#   max_capacity       = 100
#   min_capacity       = 5
#   resource_id        = "table/${aws_dynamodb_table.mapping.id}"
#   scalable_dimension = "dynamodb:table:WriteCapacityUnits"
#   service_namespace  = "dynamodb"
# }

# resource "aws_appautoscaling_policy" "mainkey_write_policy" {
#   name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.mainkey_write_target.resource_id}"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = aws_appautoscaling_target.mainkey_write_target.resource_id
#   scalable_dimension = aws_appautoscaling_target.mainkey_write_target.scalable_dimension
#   service_namespace  = aws_appautoscaling_target.mainkey_write_target.service_namespace

#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "DynamoDBWriteCapacityUtilization"
#     }

#     target_value = 70
#   }
# }


# ========================================
# Indexes autoscaling
# ========================================
# resource "aws_appautoscaling_target" "index_read_target" {
#   for_each = local.index_attributes

#   max_capacity       = 100
#   min_capacity       = 5
#   resource_id        = "table/${aws_dynamodb_table.mapping.id}/index/${each.value["name"]}"
#   scalable_dimension = "dynamodb:index:ReadCapacityUnits"
#   service_namespace  = "dynamodb"
# }

# resource "aws_appautoscaling_policy" "index_read_policy" {
#   for_each = local.index_attributes

#   name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.index_read_target[each.key].resource_id}"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = aws_appautoscaling_target.index_read_target[each.key].resource_id
#   scalable_dimension = aws_appautoscaling_target.index_read_target[each.key].scalable_dimension
#   service_namespace  = aws_appautoscaling_target.index_read_target[each.key].service_namespace

#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "DynamoDBReadCapacityUtilization"
#     }

#     target_value = 70
#   }
# }

# resource "aws_appautoscaling_target" "index_write_target" {
#   for_each = local.index_attributes

#   max_capacity       = 100
#   min_capacity       = 5
#   resource_id        = "table/${aws_dynamodb_table.mapping.id}/index/${each.value["name"]}"
#   scalable_dimension = "dynamodb:index:WriteCapacityUnits"
#   service_namespace  = "dynamodb"
# }

# resource "aws_appautoscaling_policy" "index_write_policy" {
#   for_each = local.index_attributes

#   name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.index_write_target[each.key].resource_id}"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = aws_appautoscaling_target.index_write_target[each.key].resource_id
#   scalable_dimension = aws_appautoscaling_target.index_write_target[each.key].scalable_dimension
#   service_namespace  = aws_appautoscaling_target.index_write_target[each.key].service_namespace

#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "DynamoDBWriteCapacityUtilization"
#     }

#     target_value = 70
#   }
# }
