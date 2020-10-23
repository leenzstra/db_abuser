
<?php 
    include("connect.php");
    $dbname = $_POST['db'];
    $connection = conn($dbname);

    $queryResult = $connection->
        query($_POST["query"]);

    if ($queryResult == false){
        $result = "query-error";
    }
    else{
        $result = "OK";
    }
    $arr["result"] = $result;
    echo json_encode($arr);
?>