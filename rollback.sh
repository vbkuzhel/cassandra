#!/bin/bash
_BACKUP_DIR=/backup
_DATA_DIR=/var/lib/cassandra/data
#####do not cahneg anything below
_NODETOOL=$(which nodetool)
_COMMIT_LOGS=/var/lib/cassandra/commitlog/*
_SOURCE=`ls -ltr /backup | grep '^d' | tail -1|awk '{print $NF}'`
sudo service cassandra stop;
rm -rf $_COMMIT_LOGS/*
_KEYSPACES=`ls $_BACKUP_DIR/$_SOURCE/SNAPSHOTS`
for keyspace in $_KEYSPACES; do
	_TABLES=`ls $_BACKUP_DIR/$_SOURCE/SNAPSHOTS/$keyspace`
	echo "   "$keyspace
		for table in $_TABLES; do
			echo "      "$table
			snapshotsdir=$_BACKUP_DIR/$_SOURCE/SNAPSHOTS/$keyspace/$table/snapshots
			snapshot=`ls $snapshotsdir`
			snapshotdir=$snapshotsdir/$snapshot
			echo $snapshotdir
			restoredir=$_DATA_DIR/$keyspace/$table
			echo $restoredir
			rm -f $restoredir/*.db
			cp $snapshotdir/*.db $restoredir/
		done
done
sudo service cassandra start;
sleep 10
for keyspace in $_KEYSPACES; do
	_TABLES=`ls $_BACKUP_DIR/$_SOURCE/SNAPSHOTS/$keyspace`
	echo "   "$keyspace
		for table in $_TABLES; do
			$_NODETOOL refresh $keyspace $table
		done
done
