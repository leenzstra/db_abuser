<?php
    include("connect.php");
    $dbname = $_POST['db'];
    $connection = conn($dbname);
    $queryResult = $connection->query($_POST['query']);
    if ($queryResult != false){
        if ($queryResult->num_rows == 0){
            $result = "empty-table-error";
        }
        else{
            while ($row = $queryResult->fetch_assoc()) {
                $arr[] = $row;
            }
            $result = "OK";
        }
    }
    
    else if($queryResult == false){
        $result = "query-error";
    }
    $getArr["result"] = $result;
    $getArr["data"] = $arr;
    echo json_encode($getArr);