<?php
    include("connect.php");
    $queryResult = $connection->query($_POST['query']);
    if ($queryResult != false){
        while ($row = $queryResult->fetch(PDO::FETCH_ASSOC)) {
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