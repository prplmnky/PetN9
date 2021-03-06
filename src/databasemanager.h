#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlError>
#include <QFile>

#include "models/pet.h"
#include "models/spritemodel.h"

/**
  Manages database connections for the application.
  */
class DatabaseManager : public QObject {
    Q_OBJECT
public:
    /**
      Opens a new SQLite Database at the given path.
      <p>
      A new SQLite Database is created if not already existing at path.

      @param dbPath is the path to the DB file
      */
    explicit DatabaseManager(const QString& dbPath, QObject* parent=0);
    ~DatabaseManager();

    void updateLastFedTimestamp(const Pet& pet);

    long getLastFedTimestamp(const Pet& pet);

    long getLastPoop(const Pet& pet);

    long getLastAppStart(const Pet& pet);

    /**
      Opens a conection to the database.

      @return true if the connection was succesful.
      */
    bool open();
    /**
      Closes a database connection.
      */
    void close();
    /**
      Returns the last given DB error.

      @return the last SQL error.
      */
    QSqlError lastError();

    /**
      Returns the pets created by user.
      @return the query to retrieve the pets.
      */
    QSqlQuery getPets();

    /**
      Returns the sprite models within the DB.
      @return the query to retrieve sprite objects.
      */
    QSqlQuery getSprites(SpriteModel::SPRITES typeId);

    /**
      Inserts a new Pet Model into the database.
      @return true if successful.
      */
    bool insertPetRecord(const Pet& pet);

    /**
      Inserts a new Sprite Model into the database.
      @return true if successful.
      */
    QSqlQuery insertSpriteRecord(const SpriteModel& spriteModel);

    bool deleteSpriteModel(const SpriteModel& spriteModel);

    void updateLastAppStartTimestamp(const Pet& pet);
    void updateLastPoopTimestamp(const Pet& pet);
    bool deletePetRecord(const Pet& petModel);
private:
    QSqlDatabase db;
    QString dbPath;

    void initStatus(int petId);
    QSqlQuery getStatus(const Pet& pet);
};

#endif // DATABASEMANAGER_H
