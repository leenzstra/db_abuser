<?php
    include("connect.php");
    $dbname = $_POST['db'];
    $connection = conn($dbname);
    
    $queryResult = $connection->query($_POST['query']);
    if ($queryResult != false){
        while ($row = $queryResult->fetch_assoc()) {
            $arr[] = $row["Field"];
        }
        if (count($arr) == 0){
            $result = "empty-table-error";
        }
        else{
            $result = "OK";
        }
    }
    else{
        $result = "query-error";
    }
    $getArr["result"] = $result;
    $getArr["data"] = $arr;
    echo json_encode($getArr);